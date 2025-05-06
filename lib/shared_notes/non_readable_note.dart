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

import 'package:podnotes/constants/app.dart';
import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/nav_screen.dart';
import 'package:podnotes/widgets/msg_card.dart';

class NonReadableNote extends StatefulWidget {
  final List noteMetaData;
  final String webId;
  final Map authData;

  const NonReadableNote({
    super.key,
    required this.noteMetaData,
    required this.webId,
    required this.authData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _NonReadableNoteState createState() => _NonReadableNoteState();
}

class _NonReadableNoteState extends State<NonReadableNote> {
  @override
  Widget build(BuildContext context) {
    List noteMetaData = widget.noteMetaData;

    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 10, 5),
                child: Text(
                  'Note file name: ${noteMetaData[0]}',
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
                  'Sharedy by: ${noteMetaData[1]}',
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
                  'Note path: ${noteMetaData[2]}',
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
                  'Permissions: ${noteMetaData[3]}',
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
              // if(accessList.contains('Control')) ... [
              //   shareNote(noteData, context, widget.authData, widget.webId),
              //   const SizedBox(
              //     width: 5,
              //   ),
              // ],

              // if(accessList.contains('Write') && accessList.contains('Read')) ... [
              //   ElevatedButton.icon(
              //     icon: const Icon(
              //       Icons.edit,
              //       color: Colors.white,
              //     ),
              //     onPressed: () async {
              //       Navigator.pushAndRemoveUntil(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => NavigationScreen(
              //                     webId: widget.webId,
              //                     authData: widget.authData,
              //                     page: 'editSharedNote',
              //                     sharedNoteData: noteData['noteMetadata'],
              //                   )),
              //           (Route<dynamic> route) =>
              //               false, // This predicate ensures all previous routes are removed
              //         );
              //     },
              //     style: ElevatedButton.styleFrom(
              //       foregroundColor: darkGreen,
              //       backgroundColor: lightGreen, // foreground
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 15,
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //     ),
              //     label: const Text(
              //       'EDIT',
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   ),
              //   const SizedBox(
              //     width: 5,
              //   ),
              // ],

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
  }
}
