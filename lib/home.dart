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
/// Authors: Graham Williams, Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/utils/encryption.dart';
import 'package:notepod/widgets/err_dialogs.dart';
import 'package:notepod/widgets/loading_animation.dart';
import 'package:notepod/widgets/markdown_editor.dart';
import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';

class Home extends StatefulWidget {
  // final String webId;
  // final Map authData;

  const Home({
    super.key,
  });

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormBuilderState>();

  TextEditingController? _textController;
  late final FocusNode _focusNode;

  String data = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    // Start listening to changes.
    _textController!.addListener(_renderMarkdown);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController!.dispose(); // Dispose the TextEditingController
    _focusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  void _renderMarkdown() {
    setState(() {
      data = _textController!.text;
      ;
    });
  }

  @override
  Widget build(BuildContext context) {
    String dateStr =
        DateFormat('dd MMMM yyyy').format(DateTime.now()).toString();

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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: $dateStr',
                          style: titleStyle,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    FormBuilderTextField(
                      name: 'noteTitle',
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Note Title',
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
          markdownEditor(context, _textController!, _focusNode, data),

          // av: 20250604 - The following code is from the package
          // markdown_editor_plus. The current version of this gives some errors
          // when inputting different styles such as checkboxes.
          // SplittedMarkdownFormField(
          //   controller: _textController,
          //   markdownSyntax: '## Headline',
          //   decoration: const InputDecoration(
          //     hintText: 'Editable text',
          //   ),
          //   emojiConvert: true,
          // ),

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
                      // Loading animation
                      showAnimationDialog(
                        context,
                        17,
                        'Saving the note!',
                        false,
                      );

                      Map formData = formKey.currentState?.value as Map;
                      String noteText = _textController!.text;
                      // Note title need to be spaceless as we are using that name
                      // to create a .acl file. And the acl file url cannot have spaces
                      // String noteTitle =
                      //     formData['noteTitle'].split(' ').join('_');

                      if (noteText.trim() != '') {
                        String noteTitle =
                            formData['noteTitle'].replaceAll('\n', '');

                        // Get date and time
                        String dateTimeStr = DateFormat('yyyyMMddTHHmmss')
                            .format(DateTime.now())
                            .toString();

                        // Encrypt note text using created time as the key
                        // av: 20250519 - We need to encrypt the note text because
                        // at the moment rdflib cannot parse multiline text with
                        // # (hash) values in them.
                        String encNoteText = encryptVal(noteText, dateTimeStr);

                        // Create note file name
                        // String noteFileName =
                        //     '$noteFileNamePrefix$noteTitle-$dateTimeStr.ttl';
                        String noteFileName =
                            '$noteFileNamePrefix$dateTimeStr.ttl';

                        // Create TTL body for note
                        final noteTTLStr = genNoteTTLStr(
                            dateTimeStr, dateTimeStr, noteTitle, encNoteText);

                        final createNoteStatus = await writePod(
                          noteFileName,
                          noteTTLStr,
                          context,
                          Home(),
                          //encrypted: false, // save in plain text for now
                        );

                        if (createNoteStatus ==
                            SolidFunctionCallStatus.success) {
                          //Navigator.pop(context);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppScreen(
                                title: topBarTitle,
                                childPage: Home(),
                              ),
                            ),
                            (Route<dynamic> route) =>
                                false, // This predicate ensures all previous routes are removed
                          );
                        } else {
                          Navigator.pop(context);
                          showErrDialog(context,
                              'Failed to store the note file in your POD. Try again!');
                        }
                      } else {
                        Navigator.pop(context);
                        showErrDialog(
                            context, 'Please enter some note content.');
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
                    'SAVE NOTE',
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

  // Container markdownEditor(double cardWidth,
  //     TextEditingController textController, FocusNode focusNode) {
  //   return Container(
  //     padding: const EdgeInsets.all(10),
  //     child: Row(
  //       children: [
  //         Column(
  //           children: [
  //             SizedBox(
  //               width: cardWidth,
  //               child: TextField(
  //                 autofocus: true,
  //                 controller: textController,
  //                 focusNode: focusNode,
  //                 keyboardType: TextInputType.multiline,
  //                 maxLines: null,
  //                 decoration: InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   labelText: 'Note content',
  //                 ),
  //               ),
  //             ),
  //             SizedBox(
  //               height: 10,
  //             ),
  //             SizedBox(
  //               width: cardWidth,
  //               child: MarkdownToolbar(
  //                 useIncludedTextField:
  //                     false, // Because we want to use our own, set useIncludedTextField to false
  //                 controller: textController, // Add the _controller
  //                 focusNode: focusNode, // Add the _focusNode
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(
  //           width: 20,
  //         ),
  //         Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(width: cardWidth, child: MarkdownBlock(data: data))
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }
}
