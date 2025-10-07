/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-16 10:18:07 +1000 Graham Williams>
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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/shared_notes/edit_shared_note.dart';
import 'package:notepod/shared_notes/share_external_note.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_display_markdown.dart';
import 'package:notepod/widgets/note_display_metadata.dart';
import 'package:notepod/widgets/note_edit_button.dart';
import 'package:notepod/widgets/note_share_button.dart';

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
  // /// Scroll controller for single child scroll view
  // final ScrollController _scrollController = ScrollController();
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

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
    Map sharedNoteInfo = widget.fullNoteData['sharedNoteInfo'];
    Map sharedNoteContent = widget.fullNoteData['sharedNoteContent'];
    List accessList = sharedNoteInfo[permissionListPred].split(',');

    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
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
                  // Display note metadata - show dates and sharing info, but not path info (as only shown on non readable note pag)
                  NoteDisplayMetadata(
                    fullNoteData: widget.fullNoteData,
                    showDates: true,
                    showSharing: true,
                  ),
                  // Display markdown note content
                  noteDisplayMarkdown(sharedNoteContent[noteContentPred]),
                ],
              ),
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
                  // Share if control access
                  if (accessList.contains('control')) ...[
                    NoteShareButton(
                      childPage: ShareExternalNote(
                        // noteMetaData: noteMetaData,
                        fullNoteData: widget.fullNoteData,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                  // Edit if write access
                  if (accessList.contains('write')) ...[
                    NoteEditButton(
                      childPage: EditSharedNote(
                        fullNoteData: widget.fullNoteData,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    // Back
                    NoteBackButton(childPage: SharedNotesScreen()),
                  ],
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
