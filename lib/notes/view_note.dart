/// A widget to view the content of a note.
///
// Time-stamp: <Tuesday 2025-10-21 08:44:50 +1100 Graham Williams>
///
/// Copyright (C) 2023-2025 Software Innovation Institute, ANU
///
/// License: GNU General Public License, Version 3 (the "License")
///
/// https://opensource.org/license/gpl-3-0
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
/// Authors: Anushka Vidanage, Jess Moore, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/models/own_note.dart';
import 'package:notepod/notes/edit_note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/share_note.dart';
import 'package:notepod/widgets/note_action_button.dart';
import 'package:notepod/widgets/note_del_button.dart';
import 'package:notepod/widgets/note_display_markdown.dart';
import 'package:notepod/widgets/note_display_metadata.dart';

/// A [StatefulWidget] to display the text and selected metadata
/// from the [note] of the selected note. Action buttons are
/// provided to edit and share the note, or go back to the note list.
/// Parameters:
///   [note] comprises the data object for the selected note.
class ViewNote extends StatefulWidget {
  final FoundOwnNote note;

  const ViewNote({
    super.key,
    required this.note,
  });

  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  /// Note
  late final FoundOwnNote _note;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _note = widget.note;
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 10, 5),
                          child: Text(
                            _note.content.noteTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Display note metadata
                  DisplayNoteMetadata(
                    createdDateTime: _note.content.createdDateTime,
                    modifiedDateTime: _note.content.modifiedDateTime,
                    noteFileName: _note.noteFileName,
                    showDates: true,
                    showFileName: true,
                  ),
                  // Display markdown note content
                  noteDisplayMarkdown(
                    _note.content.noteContent,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Action buttons - always visible
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Derive whether window is narrow
                  isNarrow = WindowSize().isNarrowWindow(constraints);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 5.0,
                    children: [
                      // Share button
                      NoteActionButton(
                        label: ButtonLabel.share,
                        icon: const Icon(Icons.share),
                        backgroundColor: ButtonBackgroundColor.share,
                        childPage: ShareNote(
                          note: _note,
                          backPage: ViewNote(
                            note: _note,
                          ),
                        ),
                        isNarrow: isNarrow,
                      ),

                      // Edit button
                      NoteActionButton(
                        label: ButtonLabel.edit,
                        icon: const Icon(Icons.edit),
                        backgroundColor: ButtonBackgroundColor.edit,
                        childPage: EditNote(
                          note: _note,
                        ),
                        isNarrow: isNarrow,
                      ),

                      /// Delete button
                      NoteDelButton(
                        filename: _note.noteFileName,
                        isExternal: false,
                        isNarrow: isNarrow,
                        childPage: const ListNotesScreen(),
                      ),
                      // Back button
                      NoteActionButton(
                        label: ButtonLabel.back,
                        icon: const Icon(Icons.keyboard_backspace),
                        backgroundColor: ButtonBackgroundColor.back,
                        childPage: const ListNotesScreen(),
                        isNarrow: isNarrow,
                      ),
                      // Add space
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  );
                },
              ),
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
