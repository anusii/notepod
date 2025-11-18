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

import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/paths.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/models/unparseable_note.dart';
import 'package:notepod/utils/nav_to_child.dart';
import 'package:notepod/widgets/err_card.dart';
import 'package:notepod/widgets/loading_animation.dart';

/// A delete button widget for deleting a list of notes.
///
/// Arguments:
/// - [unparseableNotes] - list of unparseable notes.
/// - [childPage] - child widget to return to.
/// - [isExternal] - flag denoting whether note is an external
/// note shared to the user.

class NoteListDelButton extends StatelessWidget {
  final List<UnparseableNote> unparseableNotes;
  final Widget childPage;
  final bool isExternal;

  const NoteListDelButton({
    super.key,
    required this.unparseableNotes,
    required this.childPage,
    this.isExternal = false,
  });

  @override
  Widget build(BuildContext context) {
    return (!isExternal)
        ? ElevatedButton.icon(
            // Uses Theme elevatedButtonTheme for all properties
            // except background color
            icon: const Icon(
              Icons.delete,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: const Text(Msg.plsConfirm),
                    content: Text(
                      unparseableNotes.length > 1
                          ? Msg.confirmDeleteMultiple
                          : Msg.confirmDelete,
                    ),
                    actions: [
                      // The "Yes" button
                      TextButton(
                        onPressed: () async {
                          showAnimationDialog(
                            context,
                            Msg.deletingNote,
                            false,
                          );

                          // Delete file
                          for (final UnparseableNote note in unparseableNotes) {
                            // Create note file path
                            String noteFilePath =
                                '$basePath/${note.noteFileName}';
                            debugPrint('Deleting $noteFilePath...');

                            // Call solid delete file function
                            if (!isExternal) {
                              await deleteFile(noteFilePath);
                            } else {
                              debugPrint(
                                '[NoteListDelButton] delete external files not yet supported',
                              );
                            }
                          }

                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true)
                                .pop(); // Dismiss the deleting note dialog

                            navToChildPage(
                              context: context,
                              childPage: childPage,
                            );
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
