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

import 'package:markdown_tooltip/markdown_tooltip.dart';
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
/// - [isSelectionMode] - flag denoting whether notes were selected.
/// - [isExtFileSelected] - flag denoting whether an external note
///  in selection.
/// - [isExternal] - flag denoting whether note is an external
/// note shared to the user.

class NoteListDelButton extends StatelessWidget {
  final List<SelectedNote> selectedNotes;
  final Widget childPage;
  final SolidScaffoldController scaffoldController;
  final bool isSelectionMode;
  final bool isExtFileSelected;
  final bool isExternal;

  const NoteListDelButton({
    super.key,
    required this.selectedNotes,
    required this.childPage,
    required this.scaffoldController,
    this.isSelectionMode = false,
    this.isExtFileSelected = false,
    this.isExternal = false,
  });

  Future<dynamic> deleteListDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text(Msg.plsConfirm),
          content: _DeleteConfirmContent(selectedNotes: selectedNotes),
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
            ? MarkdownTooltip(
                message: isExtFileSelected
                    ? 'You cannot delete notes owned by someone else. Please remove it from the selection'
                    : 'Delete selected notes',
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  label: const Text('Delete'),
                  onPressed: isExtFileSelected
                      ? null
                      : () {
                          // Show inactive button if external file in the selection
                          deleteListDialog(context);
                        },
                ),
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

/// Stateful body for the delete-confirmation dialog.

class _DeleteConfirmContent extends StatefulWidget {
  final List<SelectedNote> selectedNotes;

  const _DeleteConfirmContent({required this.selectedNotes});

  @override
  State<_DeleteConfirmContent> createState() => _DeleteConfirmContentState();
}

class _DeleteConfirmContentState extends State<_DeleteConfirmContent> {
  late final ScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    _listScrollController = ScrollController();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Cap the dialog content at a width corresponding to roughly 80-100
    // characters of body text. On narrow screens fall back to the available
    // width minus the dialog's default horizontal inset.

    final double contentWidth =
        mediaQuery.size.width < 560 ? mediaQuery.size.width - 80 : 720;

    // Cap the file list at a fraction of the viewport so the dialog never
    // grows past the visible screen and the user can scroll through long
    // selections.

    final double maxListHeight = mediaQuery.size.height * 0.4;

    return SizedBox(
      width: contentWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.selectedNotes.length > 1
                ? Msg.confirmDeleteMultiple
                : Msg.confirmDelete,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxListHeight),
            child: Scrollbar(
              controller: _listScrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: _listScrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.only(right: 8),
                itemCount: widget.selectedNotes.length,
                itemBuilder: (context, index) {
                  final note = widget.selectedNotes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.insert_drive_file_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.noteFileName,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
