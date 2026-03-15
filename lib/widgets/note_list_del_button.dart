/// The delete note list button.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Monday 2025-10-06 16:18:01 +1100 Graham Williams>
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

import 'package:solidui/solidui.dart';

import 'package:notepod/common/rest_api/file_helper.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/models/selected_note.dart';
import 'package:notepod/widgets/err_card.dart';
import 'package:notepod/widgets/loading_animation.dart' as loading;

/// A delete button widget for deleting a list of notes.
///
/// Arguments:
/// - [selectedNotes] - list of selected notes.
/// - [childPage] - child widget to return to.
/// - [scaffoldController] - Controller for the Solid scaffold.
/// - [isSelectionMode] - flag denoting whether notes were selected
/// - [isExternal] - flag denoting whether note is an external
/// note shared to the user.

class NoteListDelButton extends StatelessWidget {
  final List<SelectedNote> selectedNotes;
  final Widget childPage;
  final SolidScaffoldController scaffoldController;
  final bool isSelectionMode;
  final bool isExternal;

  const NoteListDelButton({
    super.key,
    required this.selectedNotes,
    required this.childPage,
    required this.scaffoldController,
    this.isSelectionMode = false,
    this.isExternal = false,
  });

  Future<dynamic> deleteListDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text(Msg.plsConfirm),
          content: Text(
            selectedNotes.length > 1
                ? Msg.confirmDeleteMultiple
                : Msg.confirmDelete,
          ),
          actions: [
            // The "Yes" button
            TextButton(
              onPressed: () async {
                Navigator.of(context, rootNavigator: true)
                    .pop(); // Dismiss the deleting note dialog

                loading.showAnimationDialog(
                  context,
                  Msg.deletingNote,
                  false,
                );

                // Delete file
                for (final SelectedNote note in selectedNotes) {
                  debugPrint('Deleting ${note.noteUrl}...');

                  // Call solid delete file function
                  // Delete file
                  await NoteFileHelper().deleteNote(
                    context: context,
                    filename: note.noteFileName,
                    isExternal: isExternal,
                    child: childPage,
                  );
                }

                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true)
                      .pop(); // Dismiss the loading animation dialog
                  debugPrint('Navigating to subpage...');
                  scaffoldController.navigateToSubpage(childPage);
                }
              },
              child: const Text(ButtonLabel.yes),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(); // Dismiss the deleting note dialog
              },
              child: const Text(ButtonLabel.no),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return (!isExternal)
        ? (isSelectionMode)
            ? TextButton.icon(
                icon: const Icon(
                  Icons.delete,
                ),
                label: const Text('Delete'),
                onPressed: () {
                  deleteListDialog(context);
                },
              )
            : ElevatedButton.icon(
                // Uses Theme elevatedButtonTheme for all properties
                // except background color
                icon: const Icon(
                  Icons.delete,
                ),
                onPressed: () {
                  deleteListDialog(context);
                },
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        ButtonBackgroundColor.delete,
                      ),
                    ),
                label: const Text(
                  ButtonLabel.delete,
                ),
              )
        : errCard(
            context,
            'Deleting external files is not yet supported',
          );
  }
}
