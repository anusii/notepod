/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-16 09:08:27 +1000 Graham Williams>
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
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/utils/nav_to_child.dart';
import 'package:notepod/widgets/save_dialog.dart';

/// A stylised back button widget for notes. On click it checks if edited data exists, if found it asks if the user wants to save or not save or cancel the back action. Then it navigates to the provided child page.
///
/// Arguments:
/// - [childPage] - The child page to navigate back to.
/// - [formKey] - Key of the form to edit note metadata
/// - [textController] - Optional text controller if back is being called from note editor.
/// - [prevNoteData] - Optional map of previous data of an existing note, used if back
/// called from note editor of existing note.
/// - [notesMap] -  Map of current data of the note to write to Pod
/// - [shared] - is boolean describing whether note is an external note.

class NoteBackButton extends StatelessWidget {
  const NoteBackButton({
    super.key,
    required this.childPage,
    this.textController,
    this.formKey,
    this.prevNoteData,
    this.notesMap,
    this.shared = false,
  });

  final Widget childPage;
  final TextEditingController? textController;
  final GlobalKey<FormBuilderState>? formKey;
  final Map? prevNoteData;
  final Map? notesMap;
  final bool shared;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color
      icon: const Icon(
        Icons.keyboard_backspace,
      ),
      onPressed: () {
        if (formKey?.currentState?.saveAndValidate() ?? false) {
          if (textController != null) {
            String noteText = textController!.text;
            Map formData = formKey?.currentState?.value as Map;
            String noteTitle = formData[noteTitlePred].replaceAll('\n', '');
            if (prevNoteData != null) {
              if (noteTitle != prevNoteData![noteTitlePred] ||
                  noteText != prevNoteData![noteContentPred]) {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    // Call save/don't save/cancel dialog
                    return SaveDialog(
                      childPage: childPage,
                      textController: textController!,
                      formKey: formKey!,
                      notesMap: notesMap!,
                      prevNoteData: prevNoteData,
                      shared: shared,
                    );
                  },
                );
              } else {
                debugPrint('No unsaved changes found');
                navToChildPage(context, childPage);
              }
            }
          }
        } else {
          navToChildPage(context, childPage);
        }
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.back),
          ),
      label: const Text(
        'BACK',
      ),
    );
  }
}
