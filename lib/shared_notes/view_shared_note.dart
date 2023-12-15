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
import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/nav_screen.dart';
import 'package:podnotes/shared_notes/shared_note_controls.dart';

class ViewSharedNote extends StatefulWidget {
  final Map noteData;
  final String webId;
  final Map authData;

  const ViewSharedNote({
    super.key,
    required this.noteData,
    required this.webId,
    required this.authData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ViewSharedNoteState createState() => _ViewSharedNoteState();
}

class _ViewSharedNoteState extends State<ViewSharedNote> {
  @override
  Widget build(BuildContext context) {
    Map noteData = widget.noteData;
    List accessList = noteData['noteAccessList'].split(',');

    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 10, 5),
                child: Text(
                  noteData['noteTitle'],
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
                  "Created on: ${noteData['createdDateTime']}",
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
                  "Last modified on: ${noteData['modifiedDateTimeFormatted']}",
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
                  "Owner: ${noteData['noteOwner']}",
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
                  "Shared by: ${noteData['noteSharedBy']}",
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
                  "Permissions: ${noteData['noteAccessList']}",
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
                  data: noteData['noteContent'],
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
              if (accessList.contains('Control')) ...[
                shareNote(noteData, context, widget.authData, widget.webId),
                const SizedBox(
                  width: 5,
                ),
              ],
              if (accessList.contains('Write')) ...[
                editNote(context, noteData, widget.authData, widget.webId),
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
                        builder: (context) => NavigationScreen(
                              webId: widget.webId,
                              authData: widget.authData,
                              page: 'sharedNotes',
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
