/// A stateful widget for unreadable externally owned note.
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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/share_note.dart';
import 'package:notepod/widgets/msg_card.dart';
import 'package:notepod/widgets/note_action_button.dart';
import 'package:notepod/widgets/note_display_metadata.dart';

/// A [stateful] widget for displaying a message when the user tries to view
/// an externally owned widget shared to the user.
///
/// Arguments:
/// - [note] - The externally owned note shared to the user.

class NonReadableNote extends StatefulWidget {
  final Note note;
  final SolidScaffoldController scaffoldController;

  const NonReadableNote({
    super.key,
    required this.note,
    required this.scaffoldController,
  });

  @override
  State<NonReadableNote> createState() => _NonReadableNoteState();
}

class _NonReadableNoteState extends State<NonReadableNote> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  /// Note
  late final Note _note;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scaffoldController = widget.scaffoldController;
    _note = widget.note;
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            // Display note metadata - show sharing and path info but not dates (as requires noteContent)
            DisplayNoteMetadata(
              noteOwner: _note.noteOwner,
              permissionGranter: _note.permissionGranter!,
              permissionList: _note.permissionList,
              noteFileName: _note.noteFileName,
              noteUrl: _note.noteUrl,
              showFileName: true,
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
                    spacing: 5.0,
                    children: [
                      // Share button
                      if (_note.permissionList.contains('control')) ...[
                        NoteActionButton(
                          label: ButtonLabel.share,
                          icon: const Icon(Icons.share),
                          backgroundColor: ButtonBackgroundColor.share,
                          childPage: ShareNote(
                            noteUrl: _note.noteUrl,
                            noteOwner: _note.noteOwner,
                            isExternal: _note.isExternalRes,
                            backPage: ListNotesScreen(
                              scaffoldController: _scaffoldController,
                            ),
                            scaffoldController: _scaffoldController,
                          ),
                          scaffoldController: _scaffoldController,
                          isNarrow: isNarrow,
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
                        childPage: ListNotesScreen(
                          scaffoldController: _scaffoldController,
                        ),
                        scaffoldController: _scaffoldController,
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
          ],
        ),
      ),
    );
  }
}
