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

import 'package:solidpod/solidpod.dart';

import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/notes/edit_note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/share_note.dart';
import 'package:notepod/widgets/loading_animation.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_display_markdown.dart';
import 'package:notepod/widgets/note_display_metadata.dart';
import 'package:notepod/widgets/note_edit_button.dart';

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
// <<<<<<< HEAD
              // ElevatedButton.icon(
              //   icon: const Icon(
              //     Icons.share,
              //     color: Colors.white,
              //   ),
              //   onPressed: () async {
              //     // Get note file path
              //     String noteFilePath =
              //         '$noteFileNamePrefix${noteData[createdDateTimePred]}.ttl';

              //     // redirect
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => AppScreen(
              //                 title: topBarTitle,
              //                 childPage: ShareNote(
              //                   noteData: noteData,
              //                   noteFilePath: noteFilePath,
              //                 ),
              //               )),
              //       (Route<dynamic> route) =>
              //           false, // This predicate ensures all previous routes are removed
              //     );
              //   },
              //   style: ElevatedButton.styleFrom(
              //     foregroundColor: darkBlue,
              //     backgroundColor: lightBlue, // foreground
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 15,
              //     ),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //   ),
              //   label: const Text(
              //     'SHARE',
              //     style: TextStyle(color: Colors.white),
              //   ),
              // ),
              // const SizedBox(
              //   width: 5,
              // ),
              // // Edit
              // NoteEditButton(
              //   childPage: EditNote(
              //     noteData: noteData,
              //   ),
// =======
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
// >>>>>>> dev
              ),
            ],
          ),
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

                // Edit
                NoteEditButton(
                  childPage: EditNote(
                    noteData: noteData,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),

                /// Delete function: Following function is commented out
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text('Please Confirm'),
                          content: const Text(
                            'Are you sure you want to delete this note?',
                          ),
                          actions: [
                            // The "Yes" button
                            TextButton(
                              onPressed: () async {
                                showAnimationDialog(
                                  context,
                                  17,
                                  'Deleting the note!',
                                  false,
                                );

                                // Delete file
                                // Create note file path
                                String noteFilePath =
                                    '$mainResDir/$dataDir/$noteFileNamePrefix${noteData[createdDateTimePred]}.ttl';

                                // Call solid delete file function
                                await deleteFile(noteFilePath);

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AppScreen(
                                            title: topBarTitle,
                                            childPage: ListNotesScreen(),
                                          )),
                                  (Route<dynamic> route) =>
                                      false, // This predicate ensures all previous routes are removed
                                );
                              },
                              child: const Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Close the dialog
                                Navigator.of(context).pop();
                              },
                              child: const Text('No'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: darkRed,
                    backgroundColor: lightRed, // foreground
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  label: const Text(
                    'DELETE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                // Back
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
