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
/// Authors: Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';

import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/shared_notes/shared_note_controls.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';

class ViewSharedNote extends StatefulWidget {
  final Map fullNoteData;

  const ViewSharedNote({
    super.key,
    required this.fullNoteData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ViewSharedNoteState createState() => _ViewSharedNoteState();
}

class _ViewSharedNoteState extends State<ViewSharedNote> {
  @override
  Widget build(BuildContext context) {
    Map sharedNoteInfo = widget.fullNoteData['sharedNoteInfo'];
    Map sharedNoteContent = widget.fullNoteData['sharedNoteContent'];
    List accessList = sharedNoteInfo[permissionList].split(',');

    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 10, 5),
                child: Text(
                  sharedNoteContent[noteTitlePred],
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
                  'Created on: ${sharedNoteContent[createdDateTimePred]}',
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
                  'Last modified on: ${sharedNoteContent[modifiedDateTimePred]}',
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
                  'Owner: ${sharedNoteInfo[noteOwner]}',
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
                  'Shared by: ${sharedNoteInfo[permissionGranter]}',
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
                  'Permissions: ${sharedNoteInfo[permissionList]}',
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
                  data: sharedNoteContent[noteContentPred],
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
              if (accessList.contains('control')) ...[
                shareNote(context, sharedNoteContent),
                const SizedBox(
                  width: 5,
                ),
              ],
              if (accessList.contains('write')) ...[
                editNote(context, sharedNoteContent),
                const SizedBox(
                  width: 5,
                ),
              ],
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
                              childPage: SharedNotesScreen(),
                              // childPage: SharedNotes(),
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
    // Column(
    //   children: [
    //     const SizedBox(height: 20.0),
    //     const Text("Encryption Key",
    //         style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
    //     const SizedBox(height: 20.0),

    //     const SizedBox(
    //       height: 10,
    //     ),
    //     const Text("WebID",
    //         style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
    //     const SizedBox(
    //       height: 10,
    //     ),

    //     // Spacer(),

    //     // // Only show version text in mobile version.

    //     // !Responsive.isDesktop(context)
    //     //     ? Row(
    //     //         mainAxisAlignment: MainAxisAlignment.end,
    //     //         children: [
    //     //           SelectableText(
    //     //             APP_VERSION,
    //     //             style: TextStyle(
    //     //               fontSize: versionTextSize,
    //     //               color: Colors.black,
    //     //             ),
    //     //           ),
    //     //         ],
    //     //       )
    //     //     : Container(),

    //     // // Avoid the APP_VERSION disappear at the bottom.

    //     SizedBox(
    //       height: screenHeight(context) * 0.1,
    //     )
    //   ],
    // );
  }
}
