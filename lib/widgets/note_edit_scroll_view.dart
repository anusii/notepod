/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-18 16:17:37 +1000 Jess Moore>
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/shared_notes/view_shared_note_screen.dart';
import 'package:notepod/widgets/markdown_editor.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_save_button.dart';

class NoteEditScrollView extends StatelessWidget {
  const NoteEditScrollView({
    super.key,
    required this.formKey,
    required TextEditingController? textController,
    required FocusNode focusNode,
    required this.data,
    this.prevNoteData,
    required this.shared,
  })  : _textController = textController,
        _focusNode = focusNode;

  final GlobalKey<FormBuilderState> formKey;
  final TextEditingController? _textController;
  final FocusNode _focusNode;
  final String data;
  final Map? prevNoteData;
  final bool shared;

  @override
  Widget build(BuildContext context) {
    String currDateStr = '';
    Map noteContent = {};
    Map noteInfo = {};

    if (prevNoteData == null) {
      // New note: fetch current date for heading
      currDateStr =
          DateFormat('dd MMMM yyyy').format(DateTime.now()).toString();
    } else {
      // Editing existing note (shared/unshared): extract content
      if (shared) {
        noteContent = prevNoteData!['sharedNoteContent'];
        noteInfo = prevNoteData!['sharedNoteInfo'];
      } else {
        noteContent = prevNoteData as Map<dynamic, dynamic>;
      }
    }

    Row NoteEditActionBar() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: (prevNoteData == null)
            // New Note: save button only
            ? [
                NoteSaveButton(
                    textController: _textController!,
                    formKey: formKey,
                    shared: shared)
              ]
            : [
                // Edit Note: save and back buttons
                NoteSaveButton(
                    textController: _textController!,
                    formKey: formKey,
                    prevNoteData: prevNoteData,
                    shared: shared),
                const SizedBox(
                  width: 5,
                ),
                // Nav to view note or view shared note
                (shared)
                    ? NoteBackButton(
                        childPage:
                            ViewSharedNoteScreen(sharedNoteData: noteInfo))
                    : NoteBackButton(
                        childPage: ViewNote(
                            noteData: prevNoteData as Map<dynamic, dynamic>)),
              ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
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
                      },
                      autovalidateMode: AutovalidateMode.disabled,
                      skipDisabled: true,
                      child: Column(
                        children: [
                          // New note: show current date
                          if (prevNoteData == null) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${currDateStr}',
                                  style: titleStyle,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                          // Edit existing note: populated text field with
                          // previous note data
                          FormBuilderTextField(
                            name: noteTitlePred,
                            initialValue: (prevNoteData != null)
                                ? noteContent[noteTitlePred]
                                : null,
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
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        // Action buttons - always visible
        Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: NoteEditActionBar(),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }
}
