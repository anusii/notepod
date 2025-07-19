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

import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/notes/edit_note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/share_note.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_del_button.dart';
import 'package:notepod/widgets/note_display_markdown.dart';
import 'package:notepod/widgets/note_display_metadata.dart';

class ViewNote extends StatefulWidget {
  final Map noteData;

  const ViewNote({
    super.key,
    required this.noteData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ViewNoteState createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  @override
  Widget build(BuildContext context) {
    Map noteData = widget.noteData;

    return SingleChildScrollView(
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
// <<<<<<< HEAD
//               const SizedBox(
//                 width: 5,
//               ),

//               /// Delete button
//               NoteDelButton(noteData: noteData),
//               const SizedBox(
//                 width: 5,
//               ),
//               // Back button
//               NoteBackButton(childPage: ListNotesScreen()),
// =======
// >>>>>>> dev
          //   ],
          // ),
          // Display note metadata
          NoteDisplayMetadata(data: noteData, shared: false),
          Divider(),
          // Display markdown note content
          noteDisplayMarkdown(noteData[noteContentPred]),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    // Get note file path
                    String noteFilePath =
                        '$noteFileNamePrefix${noteData[createdDateTimePred]}.ttl';

                    // redirect
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AppScreen(
                                title: topBarTitle,
                                childPage: ShareNote(
                                  noteData: noteData,
                                  noteFilePath: noteFilePath,
                                ),
                              )),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: darkBlue,
                    backgroundColor: lightBlue, // foreground
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  label: const Text(
                    'SHARE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppScreen(
                          title: topBarTitle,
                          childPage: EditNote(
                            noteData: noteData,
                          ),
                        ),
                      ),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: darkGreen,
                    backgroundColor: lightGreen, // foreground
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  label: const Text(
                    'EDIT',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),

                /// Delete button
                NoteDelButton(noteData: noteData),
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
    );
  }
}
