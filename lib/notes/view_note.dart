/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-16 10:22:24 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025 Software Innovation Institute, ANU
///
/// License: GNU General Public License, Version 3 (the "License")
///
/// https://www.gnu.org/licenses/gpl-3.0.en.html
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
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Anushka Vidanage, Jess Moore, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/notes/edit_note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/share_note.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_del_button.dart';
import 'package:notepod/widgets/note_display_markdown.dart';
import 'package:notepod/widgets/note_display_metadata.dart';
import 'package:notepod/widgets/note_edit_button.dart';
import 'package:notepod/widgets/note_share_button.dart';

/// A [StatefulWidget] to display the text and selected metadata
/// from the [noteData] of the selected note. Action buttons are
/// provided to edit and share the note, or go back to the note list.
/// Parameters:
///   [noteData] comprises the map of data for the selected note.
///   [notesMap] comprises the map of data for all note files, owned
///              by the user in their Pod (required to support
///              WebId suggestions in note sharing).
class ViewNote extends StatefulWidget {
  final Map noteData;
  final Map? notesMap;

  const ViewNote({
    super.key,
    required this.noteData,
    this.notesMap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ViewNoteState createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  @override
  Widget build(BuildContext context) {
    Map noteData = widget.noteData;

    // Get note file path
    String noteFilePath =
        '$noteFileNamePrefix${noteData[createdDateTimePred]}.ttl';

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 10, 5),
                        child: Text(
                          noteData[noteTitlePred],
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
                NoteDisplayMetadata(noteContent: noteData, showDates: true),
                Divider(),
                // Display markdown note content
                noteDisplayMarkdown(noteData[noteContentPred]),
              ],
            ),
          ),
        ),
        // Action buttons - always visible
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Share button
                  NoteShareButton(
                      childPage: ShareNote(
                          noteData: noteData,
                          noteFilePath: noteFilePath,
                          notesMap: widget.notesMap as Map<dynamic, dynamic>)),
                  const SizedBox(
                    width: 5,
                  ),
                  // Edit button
                  NoteEditButton(
                    childPage: EditNote(
                      noteData: noteData,
                      notesMap: widget.notesMap as Map<dynamic, dynamic>,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),

                  /// Delete button
                  NoteDelButton(noteData: noteData, shared: false),
                  const SizedBox(
                    width: 5,
                  ),
                  // Back button
                  NoteBackButton(childPage: ListNotesScreen()),
                ],
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
