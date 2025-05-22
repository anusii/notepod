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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/file_structure.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/utils/encryption.dart';
import 'package:notepod/widgets/err_dialogs.dart';
import 'package:notepod/widgets/loading_animation.dart';
import 'package:solidpod/solidpod.dart';
import 'package:notepod/app_screen.dart';

class EditNote extends StatefulWidget {
  final Map noteData;

  const EditNote({super.key, required this.noteData});

  @override
  EditNoteState createState() => EditNoteState();
}

class EditNoteState extends State<EditNote>
    with SingleTickerProviderStateMixin {
  TextEditingController? _textController;
  final formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    _textController!.text = widget.noteData[noteContentPred];
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
                      name: noteTitlePred,
                      initialValue: widget.noteData[noteTitlePred],
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
                      String noteTitle =
                          formData[noteTitlePred].replaceAll('\n', '');

                      if (noteTitle == prevNoteData[noteTitlePred] &&
                          noteText == prevNoteData[noteContentPred]) {
                        showErrDialog(context, 'You have no new changes!');
                      } else {
                        // Loading animation
                        showAnimationDialog(
                          context,
                          17,
                          'Saving the changes!',
                          false,
                        );

                        // Get note created time
                        String createdDateTimeStr =
                            prevNoteData[createdDateTimePred];

                        // Get date and time
                        String modifiedDateTimeStr =
                            DateFormat('yyyyMMddTHHmmss')
                                .format(DateTime.now())
                                .toString();

                        // Create new note data map
                        Map noteNewData = {};
                        noteNewData[noteTitlePred] = noteTitle;
                        noteNewData[createdDateTimePred] = createdDateTimeStr;
                        noteNewData[modifiedDateTimePred] = modifiedDateTimeStr;
                        noteNewData[noteContentPred] = noteText;

                        // Encrypt note text using created time as the key
                        // av: 20250519 - We need to encrypt the note text because
                        // at the moment rdflib cannot parse multiline text with
                        // # (hash) values in them.
                        String encNoteText = encryptVal(
                            noteText, prevNoteData[createdDateTimePred]);

                        // Create TTL body for note
                        final noteTTLStr = genNoteTTLStr(createdDateTimeStr,
                            modifiedDateTimeStr, noteTitle, encNoteText);

                        // Create note file name
                        String noteFileName =
                            '$myNotesDir/$noteFileNamePrefix$createdDateTimeStr.ttl';

                        final createNoteStatus = await writePod(
                          noteFileName,
                          noteTTLStr,
                          context,
                          EditNote(
                            noteData: noteNewData,
                          ),
                          encrypted: false, // save in plain text for now
                        );

                        if (createNoteStatus ==
                            SolidFunctionCallStatus.success) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppScreen(
                                title: topBarTitle,
                                childPage: ViewNote(noteData: noteNewData),
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
                      horizontal: 30,
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
                const SizedBox(
                  width: 5,
                ),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.keyboard_backspace,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AppScreen(
                                title: topBarTitle,
                                childPage: ViewNote(noteData: widget.noteData),
                              )),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: titleAsh,
                    backgroundColor: lightGray, // foreground
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  label: const Text(
                    'GO BACK',
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
