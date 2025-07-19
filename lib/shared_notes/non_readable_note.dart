/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-16 10:19:02 +1000 Graham Williams>
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
/// Authors: Anushka Vidanage, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/shared_notes/share_external_note.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';
import 'package:notepod/widgets/loading_animation.dart';
import 'package:notepod/widgets/msg_card.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_share_button.dart';

class NonReadableNote extends StatefulWidget {
  final Map noteMetaData;

  const NonReadableNote({
    super.key,
    required this.noteMetaData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _NonReadableNoteState createState() => _NonReadableNoteState();
}

class _NonReadableNoteState extends State<NonReadableNote> {
  @override
  Widget build(BuildContext context) {
    Map noteMetaData = widget.noteMetaData;

    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 10, 5),
                child: Text(
                  'Note file name: ${noteMetaData[noteFileName]}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 5, 10, 0),
                child: Text(
                  'Sharedy by: ${noteMetaData[noteOwner]}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 5, 10, 0),
                child: Text(
                  'Note path: ${noteMetaData[noteUrl]}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 5, 10, 10),
                child: Text(
                  'Permissions: ${noteMetaData[permissionList]}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        buildMsgCard(
          context,
          Icons.info,
          Colors.amber,
          'Access Permission!',
          nonReadableNoteMsg,
        ),
        Expanded(
          child: SizedBox(
            child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (noteMetaData[permissionList].contains('control')) ...[
                NoteShareButton(
                  childPage: ShareExternalNote(
                    noteMetaData: noteMetaData,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
              if (noteMetaData[permissionList].contains('write')) ...[
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

                                // Call solid delete file function
                                await deleteExternalFile(noteMetaData[noteUrl]);

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AppScreen(
                                            title: topBarTitle,
                                            childPage: SharedNotesScreen(),
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
              ],
              NoteBackButton(childPage: SharedNotesScreen()),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
