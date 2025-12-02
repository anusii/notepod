/// A widget for creating and editing notes in a SingleChildScrollView()
///
// Time-stamp: <Wednesday 2025-07-18 16:17:37 +1000 Jess Moore>
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:solidui/solidui.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/external_note.dart';
import 'package:notepod/models/own_note.dart';
import 'package:notepod/widgets/markdown_editor.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_save_button.dart';

/// A [StatelessWidget] widget setup for calling the
/// SingleChildScrollView() to edit a note, whether a
/// new note or a pre-existing note, and whether owned
/// by the user or shared to the user.
class NoteEditScrollView extends StatelessWidget {
  const NoteEditScrollView({
    super.key,
    required this.formKey,
    required TextEditingController? textController,
    required ScrollController scrollController,
    required SolidScaffoldController scaffoldController,
    required FocusNode focusTitle,
    required FocusNode focusContent,
    required this.childPage,
    required this.data,
    this.prevExternalNote,
    this.prevOwnNote,
    this.isExternal = false,
    this.isExisting = false,
    this.noteTitle,
  })  : _textController = textController,
        _scrollController = scrollController,
        _scaffoldController = scaffoldController,
        _focusTitle = focusTitle,
        _focusContent = focusContent;

  final GlobalKey<FormBuilderState> formKey;
  final TextEditingController? _textController;

  /// Scroll controller for single child scroll view
  final ScrollController _scrollController;

  /// Scaffold controller
  final SolidScaffoldController _scaffoldController;

  /// Focus node for note title field
  final FocusNode _focusTitle;

  /// Focus node for note contents text field
  final FocusNode _focusContent;

  /// Childpage used by back button
  final Widget childPage;

  final String data;

  /// Existing note data is note already exists
  final FoundExternalNote? prevExternalNote;
  final FoundOwnNote? prevOwnNote;

  /// Boolean describing whether note is shared to pod owner from an
  /// external source.
  final bool isExternal;

  /// Boolean describing whether note already exists.
  final bool isExisting;

  /// Title of note where note already exists
  final String? noteTitle;

  @override
  Widget build(BuildContext context) {
    String currDateStr = '';

    if (!isExisting) {
      // New note: fetch current date for heading
      currDateStr =
          DateFormat('dd MMMM yyyy').format(DateTime.now()).toString();
    }

    Row noteEditActionBar() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 5.0,
        children: (!isExisting)
            // New Note: save button only
            ? [
                NoteSaveButton(
                  textController: _textController!,
                  formKey: formKey,
                  scaffoldController: _scaffoldController,
                  // notesMap: notesMap,
                ),
              ]
            : [
                // Edit Note: save and back buttons
                // Save button
                (isExternal)
                    ? NoteSaveButton(
                        textController: _textController!,
                        formKey: formKey,
                        scaffoldController: _scaffoldController,
                        prevExternalNote: prevExternalNote,
                        isExisting: true,
                        isExternal: isExternal,
                      )
                    : NoteSaveButton(
                        textController: _textController!,
                        formKey: formKey,
                        scaffoldController: _scaffoldController,
                        prevOwnNote: prevOwnNote,
                        isExisting: true,
                      ),
                // Back button
                // Nav to view note or view isExternal note
                (isExternal)
                    ? NoteBackButton(
                        childPage: childPage,
                        textController: _textController,
                        formKey: formKey,
                        scaffoldController: _scaffoldController,
                        prevExternalNote: prevExternalNote,
                        isExisting: isExisting,
                        isExternal: isExternal,
                      )
                    : NoteBackButton(
                        childPage: childPage,
                        textController: _textController,
                        formKey: formKey,
                        scaffoldController: _scaffoldController,
                        prevOwnNote: prevOwnNote,
                        isExisting: isExisting,
                      ),
              ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                spacing: 10.0,
                children: [
                  // Add space
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
                        spacing: 10.0,
                        children: [
                          // New note: show current date
                          if (!isExisting) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: $currDateStr',
                                  style: titleStyle,
                                ),
                              ],
                            ),
                          ],
                          // Edit existing note: populated text field with
                          // previous note data
                          FormBuilderTextField(
                            name: noteTitlePred,
                            initialValue: (isExisting) ? noteTitle : null,
                            // Initial focus in title field
                            autofocus: true,
                            focusNode: _focusTitle,
                            decoration: const InputDecoration(
                              labelText: 'Note Title',
                              labelStyle: TextStyle(
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
                      ),
                    ),
                  ),
                  markdownEditor(
                    context,
                    _textController!,
                    _focusContent,
                    data,
                  ),
                  // Add space
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Action buttons - always visible
        Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: noteEditActionBar(),
            ),
            // Add space
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }
}
