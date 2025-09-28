/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-16 10:19:02 +1000 Graham Williams>
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
/// Authors: Anushka Vidanage, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/shared_notes/share_external_note.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';
import 'package:notepod/widgets/msg_card.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_display_metadata.dart';
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
        // Display note metadata - show sharing and path info but not dates (as requires noteContent)
        NoteDisplayMetadata(
          noteInfo: noteMetaData,
          showSharing: true,
          showPathInfo: true,
        ),
        buildMsgCard(
          context,
          Icons.info,
          Colors.amber,
          'Access Permission!',
          nonReadableNoteMsg,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Share button
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
              // /// Delete button
              // /// 20250719 jesscmoore Commented out as also commented out
              // /// external note with read-write-control-append access
              // if (noteMetaData[permissionList].contains('write')) ...[
              //   NoteDelButton(noteData: noteMetaData, shared: true),
              //   const SizedBox(
              //     width: 5,
              //   ),
              // ],
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
