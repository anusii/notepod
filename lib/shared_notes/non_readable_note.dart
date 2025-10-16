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
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/shared_notes/share_external_note.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';
import 'package:notepod/widgets/msg_card.dart';
import 'package:notepod/widgets/note_action_button.dart';
import 'package:notepod/widgets/note_display_metadata.dart';

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
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map noteMetaData = widget.noteMetaData;

    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            // Display note metadata - show sharing and path info but not dates (as requires noteContent)
            NoteDisplayMetadata(
              noteInfo: noteMetaData,
              showSharing: true,
              showPathInfo: true,
            ),
            // MsgCard style works in light and dark themes
            buildMsgCard(
              context,
              Icons.info,
              Colors.amber,
              'Access Permission!',
              nonReadableNoteMsg,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Derive whether window is narrow
                  isNarrow = WindowSize().isNarrowWindow(constraints);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Share button
                      if (noteMetaData[permissionListPred]
                          .contains('control')) ...[
                        NoteActionButton(
                          label: ButtonLabel.share,
                          icon: const Icon(Icons.share),
                          backgroundColor: ButtonBackgroundColor.share,
                          childPage: ShareExternalNote(
                            noteMetaData: noteMetaData,
                          ),
                          isNarrow: isNarrow,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                      // /// Delete button
                      // /// 20250719 jesscmoore Commented out as also commented out
                      // /// external note with read-write-control-append access
                      // if (noteMetaData[permissionListPred].contains('write')) ...[
                      //   NoteDelButton(noteData: noteMetaData, isExternal: true),
                      //   const SizedBox(
                      //     width: 5,
                      //   ),
                      // ],
                      NoteActionButton(
                        label: ButtonLabel.back,
                        icon: const Icon(Icons.keyboard_backspace),
                        backgroundColor: ButtonBackgroundColor.back,
                        childPage: const SharedNotesScreen(),
                        isNarrow: isNarrow,
                      ),
                      const SizedBox(
                        width: 10,
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
      ),
    );
  }
}
