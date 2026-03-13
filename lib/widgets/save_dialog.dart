/// A save options dialog
///
// Time-stamp: <Friday 2025-10-08 18:25:01 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
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
import 'package:solidui/solidui.dart';

import 'package:notepod/common/rest_api/file_helper.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/models/external_note.dart';
import 'package:notepod/models/note.dart';

/// A save note options dialog providing the user with the options to
/// save or don't save the note, or cancel their back action.
///
/// Arguments:
/// - [childPage] - child widget to navigate to.
/// - [textController] - text controller holding text of the note body.
///   [scaffoldController] - Controller for the Solid scaffold.
/// - [formKey] - form key holding text of the note title.
/// - [prevExternalNote] - Optional existing external note data object. Required
/// for saving existing externally owned notes. (Default: null).
/// - [prevOwnNote] - Optional existing user's note data object. Required
/// for saving existing notes owned by the user. (Default: null).
/// - [isExternal] - Optional boolean denoting whether note is externally
/// owned. (Default: false).

class SaveDialog extends StatelessWidget {
  final Widget childPage;
  final TextEditingController textController;
  final SolidScaffoldController scaffoldController;
  final GlobalKey<FormBuilderState> formKey;
  final FoundExternalNote? prevExternalNote;
  final Note? prevOwnNote;
  final bool isExternal;

  /// Only called for existing notes
  final bool isExisting = true;

  const SaveDialog({
    super.key,
    required this.childPage,
    required this.textController,
    required this.scaffoldController,
    required this.formKey,
    this.prevExternalNote,
    this.prevOwnNote,
    this.isExternal = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unsaved changes!'),
      content: const Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          primary: true,
          child: ListBody(
            children: <Widget>[
              Text(ErrMsg.unsavedChanges),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        // Save button
        TextButton(
          child: const Text('Save'),
          onPressed: () async {
            // Save note
            (isExternal)
                ? await NoteFileHelper().saveNote(
                    context: context,
                    textController: textController,
                    scaffoldController: scaffoldController,
                    formKey: formKey,
                    prevExternalNote: prevExternalNote,
                    isExisting: isExisting,
                    isExternal: isExternal,
                  )
                : await NoteFileHelper().saveNote(
                    context: context,
                    textController: textController,
                    scaffoldController: scaffoldController,
                    formKey: formKey,
                    prevOwnNote: prevOwnNote,
                    isExisting: isExisting,
                  );
          },
        ),
        // Don't save button
        TextButton(
          child: const Text('Don\'t Save'),
          onPressed: () {
            scaffoldController.navigateToSubpage(childPage);
          },
        ),
        // Cancel button
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
