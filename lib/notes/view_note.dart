/// Individual's PODs app for diabetes care in Yarrabah.
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
///
/// License: GNU General Public License, Version 3 (the "License")
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
/// Authors: Anushka Vidanage, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/file_structure.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/notes/edit_note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/share_note.dart';
import 'package:notepod/widgets/loading_animation.dart';
import 'package:notepod/app_screen.dart';

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

    return Column(
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 5, 10, 0),
                child: Text(
                  'Created on: ${noteData[createdDateTimePred]}',
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
                  'Last modified on: ${noteData[modifiedDateTimePred]}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SizedBox(
            child: Container(
                padding: const EdgeInsets.all(10),
                child: MarkdownParse(
                  data: noteData[noteContentPred],
                  // onTapHastag: (String name, String match) {
                  //   // name => hashtag
                  //   // match => #hashtag
                  // },
                  // onTapMention: (String name, String match) {
                  //   // name => mention
                  //   // match => #mention
                  // },
                )),
          ),
        ),
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
                      '$myNotesDir/$noteFileNamePrefix${noteData[createdDateTimePred]}.ttl';

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
                                  '$mainResDir/$dataDir/$myNotesDir/$noteFileNamePrefix${noteData[createdDateTimePred]}.ttl';

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

              /// uncomment upto here
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.keyboard_backspace,
                  color: Colors.white,
                ),
                onPressed: () {
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: titleAsh,
                  backgroundColor: lightGray, // foreground
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                label: const Text(
                  'GO BACK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
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
