/// A stateful widget for sharing an externally owned note.
///
// Time-stamp: <Wednesday 2025-07-16 10:19:41 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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

import 'package:solidpod/solidpod.dart';

import 'package:notepod/models/external_note.dart';
import 'package:notepod/shared_notes/list_external_notes_screen.dart';
import 'package:notepod/widgets/note_back_button.dart';

/// A [stateful] widget for sharing an externally owned note shared to the user, to share the note with another user.
///
/// Arguments:
/// - [note] - The externally owned note shared to the user.

class ShareExternalNote extends StatefulWidget {
  final ExternalNote note;

  const ShareExternalNote({
    super.key,
    required this.note,
  });

  @override
  ShareExternalNoteState createState() => ShareExternalNoteState();
}

class ShareExternalNoteState extends State<ShareExternalNote> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Note
  late final ExternalNote _note;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const NoteBackButton(
                    childPage: ListExternalNotesScreen(),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: GrantPermissionUi(
                      showAppBar: false,
                      fileName: _note.noteUrl,
                      isExternalRes: true,
                      externalWebId: _note.noteOwner,
                      child: ShareExternalNote(note: _note),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
