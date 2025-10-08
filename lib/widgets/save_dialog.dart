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

import 'package:notepod/common/rest_api/file_helper.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/utils/nav_to_child.dart';

/// A save note options dialog providing the user with the options to
/// save or don't save the note, or cancel their back action.
///
/// Arguments:
/// - [childPage] - child widget to navigate to.
/// - [textController] - text controller holding text of the note body.
/// - [formKey] - form key holding text of the note title.
/// - [prevNoteData] - map of data for an existing note.
/// - [notesMap] - map of note info.
/// - [shared] - is boolean describing whether note is an external note.

class SaveDialog extends StatelessWidget {
  final Widget childPage;
  final TextEditingController textController;
  final GlobalKey<FormBuilderState> formKey;
  final Map? prevNoteData;
  final Map notesMap;
  final bool shared;

  const SaveDialog({
    super.key,
    required this.childPage,
    required this.textController,
    required this.formKey,
    this.prevNoteData,
    required this.notesMap,
    this.shared = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unsaved changes!'),
      content: Scrollbar(
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
            await NoteFileHelper().saveNote(
              context,
              textController,
              formKey,
              prevNoteData,
              shared,
              notesMap,
            );
          },
        ),
        // Don't save button
        TextButton(
          child: const Text('Don\'t Save'),
          onPressed: () {
            navToChildPage(context, childPage);
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
