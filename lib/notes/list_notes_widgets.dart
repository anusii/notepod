/// Extracted widget helpers for the note list screen.
///
// Time-stamp: <Thursday 2026-04-30 09:00:00 +1000 Graham Williams>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidui/solidui.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/models/selected_note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/non_readable_note.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/widgets/note_item_subtitle.dart';
import 'package:notepod/widgets/note_item_trailing_buttons.dart';
import 'package:notepod/widgets/note_list_del_button.dart';

// ── NoteListCard ─────────────────────────────────────────────────────────────

class NoteListCard extends StatelessWidget {
  final Note note;
  final SolidScaffoldController scaffoldController;
  final bool isSelectionMode;
  final Decoration buttonShapeList;
  final ThemeData theme;
  final bool isVeryNarrow;
  final VoidCallback onSelect;

  const NoteListCard({
    super.key,
    required this.note,
    required this.scaffoldController,
    required this.isSelectionMode,
    required this.buttonShapeList,
    required this.theme,
    required this.isVeryNarrow,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if (note.permissionList.contains('read')) {
            scaffoldController.navigateToSubpage(
              ViewNote(note: note, scaffoldController: scaffoldController),
            );
          } else {
            scaffoldController.navigateToSubpage(
              NonReadableNote(
                note: note,
                scaffoldController: scaffoldController,
              ),
            );
          }
        },
        child: Ink(
          decoration: note.isSelected
              ? BoxDecoration(
                  color: theme.colorScheme.onInverseSurface,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: NoteIconSize.width,
                  child: Center(
                    child: MarkdownTooltip(
                      message: '**Select note**\n\nTap to select this note.',
                      child: Ink(
                        decoration: buttonShapeList,
                        child: IconButton(
                          icon: note.isSelected
                              ? const Icon(Icons.done)
                              : const Icon(Icons.edit_document),
                          onPressed: onSelect,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.permissionList.contains('read'))
                        Text(
                          note.content!.noteTitle,
                          maxLines: (!isVeryNarrow) ? 1 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      NoteItemSubtitle(note: note, isNarrow: isVeryNarrow),
                    ],
                  ),
                ),
                NoteItemTrailingButtons(
                  note: note,
                  scaffoldController: scaffoldController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── NoteListSortRow ───────────────────────────────────────────────────────────

class NoteListSortRow extends StatelessWidget {
  final bool isVeryNarrow;
  final int selectedCount;
  final int foundCount;
  final bool isSelectionMode;
  final List<SelectedNote> selectedNotes;
  final SolidScaffoldController scaffoldController;
  final bool sortTitleAscending;
  final bool sortModDateAscending;
  final bool sortFilenameAscending;
  final void Function(bool) onSortTitle;
  final void Function(bool) onSortModDate;
  final void Function(bool) onSortFilename;

  const NoteListSortRow({
    super.key,
    required this.isVeryNarrow,
    required this.selectedCount,
    required this.foundCount,
    required this.isSelectionMode,
    required this.selectedNotes,
    required this.scaffoldController,
    required this.sortTitleAscending,
    required this.sortModDateAscending,
    required this.sortFilenameAscending,
    required this.onSortTitle,
    required this.onSortModDate,
    required this.onSortFilename,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: selectedCount > 0
              ? Text(
                  'Selected: $selectedCount notes',
                  style: TextStyle(color: primary),
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  'Found $foundCount note${foundCount == 1 ? '' : 's'}',
                  style: TextStyle(color: primary),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: (!isVeryNarrow) ? 3.0 : 0,
          children: [
            if (isSelectionMode) ...[
              NoteListDelButton(
                selectedNotes: selectedNotes,
                childPage: ListNotesScreen(
                  scaffoldController: scaffoldController,
                ),
                scaffoldController: scaffoldController,
                isSelectionMode: isSelectionMode,
              ),
            ],
            TextButton.icon(
              onPressed: () => onSortTitle(!sortTitleAscending),
              icon: Icon(
                sortTitleAscending
                    ? Icons.arrow_drop_down
                    : Icons.arrow_drop_up,
              ),
              label: const Text('Title'),
              iconAlignment: IconAlignment.end,
            ),
            if (!isVeryNarrow)
              TextButton.icon(
                onPressed: () => onSortModDate(!sortModDateAscending),
                icon: Icon(
                  sortModDateAscending
                      ? Icons.arrow_drop_down
                      : Icons.arrow_drop_up,
                ),
                label: const Text('Modified'),
                iconAlignment: IconAlignment.end,
              ),
            TextButton.icon(
              onPressed: () => onSortFilename(!sortFilenameAscending),
              icon: Icon(
                sortFilenameAscending
                    ? Icons.arrow_drop_down
                    : Icons.arrow_drop_up,
              ),
              label: const Text('Filename'),
              iconAlignment: IconAlignment.end,
            ),
          ],
        ),
      ],
    );
  }
}
