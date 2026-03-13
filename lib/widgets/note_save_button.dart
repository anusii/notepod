/// The save note button.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Wednesday 2025-07-16 08:32:47 +1100 Jess Moore>
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
import 'package:solidui/solidui.dart';

import 'package:notepod/common/rest_api/file_helper.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/models/note.dart';

/// A stylised save button widget which on click saves the note content
/// Pod. External notes are written to the note owner's Pod. Notes created
/// by the user are written to the user's Pod.
///
/// Examples
/// - `NoteSaveButton(textController: _textController!, formKey: formKey, shared: shared, notesMap: notesMap)` save the metadata and content of a new note to user's Pod.
/// - `NoteSaveButton(textController: _textController!, formKey: formKey, prevNoteData: prevNoteData, shared: shared, notesMap: notesMap)` save the updated metadata and content of an existing note to the owner's Pod (whether that be the user or an external owner).
///
/// - [textController] - Text controller of the note text content editor.
/// - [formKey] - Key of the form to edit the note metadata.
///   [scaffoldController] - Controller for the Solid scaffold.
/// - [prevExternalNote] - Optional existing external note data object. Required
/// for saving existing externally owned notes. (Default: null).
/// - [prevOwnNote] - Optional existing user's note data object. Required
/// for saving existing notes owned by the user. (Default: null).
/// - [isExternal] - Optional boolean denoting whether note is externally
/// owned. (Default: false).
/// - [isExisting] - Optional boolean denoting whether note already
/// exists. (Default: false).

class NoteSaveButton extends StatelessWidget {
  final TextEditingController textController;
  final GlobalKey<FormBuilderState> formKey;
  final SolidScaffoldController scaffoldController;
  final Note? prevExternalNote;
  final Note? prevOwnNote;
  final bool isExisting;
  final bool isExternal;

  const NoteSaveButton({
    super.key,
    required this.textController,
    required this.formKey,
    required this.scaffoldController,
    this.prevExternalNote,
    this.prevOwnNote,
    this.isExisting = false,
    this.isExternal = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color and padding
      icon: const Icon(
        Icons.save,
      ),
      onPressed: () async {
        // Save note and redirect to view note page
        (isExternal)
            ? await NoteFileHelper().saveNote(
                context: context,
                textController: textController,
                formKey: formKey,
                scaffoldController: scaffoldController,
                prevExternalNote: prevExternalNote,
                isExisting: isExisting,
                isExternal: isExternal,
              )
            : await NoteFileHelper().saveNote(
                context: context,
                textController: textController,
                formKey: formKey,
                scaffoldController: scaffoldController,
                prevOwnNote: prevOwnNote,
                isExisting: isExisting,
              );
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.save),
            // Larger edgeinsets to emphasise save button
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
      label: const Text(
        'SAVE',
      ),
    );
  }
}
