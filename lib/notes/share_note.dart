/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-16 10:21:24 +1000 Graham Williams>
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
/// Authors: Anushka Vidanage, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:notepod/widgets/note_back_button.dart';

/// A [StatefulWidget] for sharing a note owned by the user.
/// Parameters:
///   [noteData] - is the data of the selected note to be shared.
///   [noteFilePath] - is the path of the selected note file.
///   [notesMap] - is the file list map with data of all notes
///                in the user's app data folder (required to support
///                sharing with suggestion list of recipient WebIds)
class ShareNote extends StatefulWidget {
  final Map noteData;
  final String noteFilePath;
  final Map notesMap;
  final Widget backPage;

  const ShareNote({
    super.key,
    required this.noteData,
    required this.noteFilePath,
    this.notesMap = const {},
    required this.backPage,
  });

  @override
  ShareNoteState createState() => ShareNoteState();
}

class ShareNoteState extends State<ShareNote>
    with SingleTickerProviderStateMixin {
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
                  NoteBackButton(
                    childPage: widget.backPage,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: GrantPermissionUi(
                      showAppBar: false,
                      fileName: widget.noteFilePath,
                      dataFilesMap: widget.notesMap as Map<String, dynamic>,
                      child: ShareNote(
                        noteData: widget.noteData,
                        noteFilePath: widget.noteFilePath,
                        notesMap: widget.notesMap,
                        backPage: widget.backPage,
                      ),
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
