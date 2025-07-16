/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-16 10:21:24 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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

import 'package:solidpod/solidpod.dart';

import 'package:notepod/notes/view_note.dart';
import 'package:notepod/widgets/note_back_button.dart';

class ShareNote extends StatefulWidget {
  final Map noteData;
  final String noteFilePath;

  const ShareNote(
      {super.key, required this.noteData, required this.noteFilePath});

  @override
  ShareNoteState createState() => ShareNoteState();
}

class ShareNoteState extends State<ShareNote>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                NoteBackButton(childPage: ViewNote(noteData: widget.noteData)),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: GrantPermissionUi(
                    showAppBar: false,
                    fileName: widget.noteFilePath,
                    child: ShareNote(
                      noteData: widget.noteData,
                      noteFilePath: widget.noteFilePath,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
