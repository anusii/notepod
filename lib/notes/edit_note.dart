/// The home page for the app.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:32:47 +1100 Graham Williams>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Graham Williams

library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:podnotes/constants/app.dart';
import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/constants/file_structure.dart';
import 'package:podnotes/common/rest_api/rest_api.dart';
import 'package:podnotes/constants/turtle_structures.dart';
import 'package:podnotes/nav_screen.dart';
import 'package:podnotes/widgets/err_dialogs.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:podnotes/widgets/loading_animation.dart';
//import 'package:simple_markdown_editor/simple_markdown_editor.dart';

class EditNote extends StatefulWidget {
  final String webId;
  final Map authData;
  final Map noteData;

  const EditNote({super.key, required this.webId, required this.authData, required this.noteData});

  @override
  EditNoteState createState() => EditNoteState();
}

class EditNoteState extends State<EditNote> with SingleTickerProviderStateMixin {
  TextEditingController? _textController;
  final formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    _textController!.text = widget.noteData['noteContent'];
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FormBuilder(
                key: formKey,
                onChanged: () {
                  formKey.currentState!.save();
                  debugPrint(formKey.currentState!.value.toString());
                },
                autovalidateMode: AutovalidateMode.disabled,
                skipDisabled: true,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'noteTitle',
                      initialValue: widget.noteData['noteTitle'],
                      decoration: const InputDecoration(
                        labelText:
                            'Note Title (Do not use underscores (_) in title)',
                        labelStyle: TextStyle(
                          color: darkBlue,
                          letterSpacing: 1.5,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                        //errorText: 'error',
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                  ],
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
              padding: const EdgeInsets.all(10),
              child: SplittedMarkdownFormField(
                controller: _textController,
                markdownSyntax: '## Headline',
                decoration: const InputDecoration(
                  hintText: 'Editable text',
                ),
                emojiConvert: true,
              )),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.saveAndValidate() ?? false) {

                      Map prevNoteData = widget.noteData;

                      Map formData = formKey.currentState?.value as Map;
                      String noteText = _textController!.text;
                      // Note title need to be spaceless as we are using that name
                      // to create a .acl file. And the acl file url cannot have spaces
                      String noteTitle = formData['noteTitle'].replaceAll('\n', '');

                      if(noteTitle == prevNoteData['noteTitle'] && noteText == prevNoteData['noteContent']){
                        showErrDialog(context, 'You have no new changes!');
                      } else {

                        // Loading animation
                        showAnimationDialog(
                          context,
                          17,
                          'Saving the changes!',
                          false,
                        );                  

                        // Get the master key
                        // String masterKey = await secureStorage.read(
                        //       key: widget.webId,
                        //     ) ??
                        //     '';

                        // Hash plaintext master key to get hashed master key
                        // String encKey = sha256
                        //     .convert(utf8.encode(masterKey))
                        //     .toString()
                        //     .substring(0, 32);

                        // Get date and time
                        String dateTimeStr = DateFormat("yyyyMMddTHHmmss")
                            .format(DateTime.now())
                            .toString();

                        // Get the random session key for this file
                        final indKeyStr = prevNoteData['encSessionKey'];

                        // Encrypt markdown text using random session key
                        final indKey = encrypt.Key.fromBase64(indKeyStr);
                        final dataEncryptIv = encrypt.IV.fromLength(16);
                        final dataEncrypter = encrypt.Encrypter(
                            encrypt.AES(indKey, mode: encrypt.AESMode.cbc));
                        final dataEncryptVal =
                            dataEncrypter.encrypt(noteText, iv: dataEncryptIv);
                        String dataEncryptValStr =
                            dataEncryptVal.base64.toString();

                        Map noteNewData = {};
                        noteNewData['noteTitle'] = noteTitle;
                        noteNewData['modifiedDateTime'] = dateTimeStr;
                        noteNewData['encContent'] = dataEncryptValStr;
                        noteNewData['encIv'] = dataEncryptIv.base64.toString();

                        // Update the file
                        String updateRes = await updateNoteFile(widget.authData, prevNoteData, noteNewData);

                        if (updateRes == 'ok') {
                          // ignore: use_build_context_synchronously
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NavigationScreen(
                                      webId: widget.webId,
                                      authData: widget.authData,
                                      page: 'listNotes',
                                    )),
                            (Route<dynamic> route) =>
                                false, // This predicate ensures all previous routes are removed
                          );
                        } else {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          // ignore: use_build_context_synchronously
                          showErrDialog(context,
                              'Failed to update the individual key. Try again!');
                        }
                      }
                      
                    } else {
                      showErrDialog(context,
                          'Note name validation failed! Try using a different name.');
                    }

                    // Redirect to the home page
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: darkBlue,
                    backgroundColor: lightBlue, // foreground
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'SAVE CHANGES',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
