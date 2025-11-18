/// A stateful widget to view an externally owned note.
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

import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/models/external_note.dart';
import 'package:notepod/shared_notes/edit_shared_note.dart';
import 'package:notepod/shared_notes/list_external_notes_screen.dart';
import 'package:notepod/shared_notes/share_external_note.dart';
import 'package:notepod/widgets/note_action_button.dart';
import 'package:notepod/widgets/note_display_markdown.dart';
import 'package:notepod/widgets/note_display_metadata.dart';

/// A [stateful] widget for viewing an externally owned note.
///
/// Arguments:
/// - [note] - The note to view.

class ViewSharedNote extends StatefulWidget {
  final FoundExternalNote note;

  const ViewSharedNote({
    super.key,
    required this.note,
  });

  @override
  State<ViewSharedNote> createState() => _ViewSharedNoteState();
}

class _ViewSharedNoteState extends State<ViewSharedNote> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  /// Note data
  late final FoundExternalNote _note;

  /// List of user's permissions
  late final List<String> _accessList;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _accessList = _note.permissionList.split(',');
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            _note.content!.noteTitle,
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
                  DisplayNoteMetadata(
                    createdDateTime: _note.content!.createdDateTime,
                    modifiedDateTime: _note.content!.modifiedDateTime,
                    noteOwner: _note.noteOwner,
                    permissionGranter: _note.permissionGranter,
                    permissionList: _note.permissionList,
                    noteFileName: _note.noteFileName,
                    noteUrl: _note.noteUrl,
                    showDates: true,
                    showFileName: true,
                    showSharing: true,
                    showPathInfo: true,
                  ),
                  // Display markdown note content
                  noteDisplayMarkdown(_note.content!.noteContent),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Derive whether window is narrow
                  isNarrow = WindowSize().isNarrowWindow(constraints);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 5.0,
                    children: [
                      // Share if control access
                      if (_accessList.contains('control')) ...[
                        NoteActionButton(
                          label: ButtonLabel.share,
                          icon: const Icon(Icons.share),
                          backgroundColor: ButtonBackgroundColor.share,
                          childPage: ShareExternalNote(
                            note: _note,
                          ),
                          isNarrow: isNarrow,
                        ),
                      ],
                      // Edit if write access
                      if (_accessList.contains('write')) ...[
                        NoteActionButton(
                          label: ButtonLabel.edit,
                          icon: const Icon(Icons.edit),
                          backgroundColor: ButtonBackgroundColor.edit,
                          childPage: EditSharedNote(
                            note: _note,
                          ),
                          isNarrow: isNarrow,
                        ),
                      ],
                      // Back
                      NoteActionButton(
                        label: ButtonLabel.back,
                        icon: const Icon(Icons.keyboard_backspace),
                        backgroundColor: ButtonBackgroundColor.back,
                        childPage: const ListExternalNotesScreen(),
                        isNarrow: isNarrow,
                      ),
                      // Add space
                      const SizedBox(
                        width: 5,
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
      ],
    );
  }
}
