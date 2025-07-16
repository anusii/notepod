/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-16 10:19:41 +1000 Graham Williams>
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
/// Authors: Anushka Vidanage, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';
import 'package:notepod/widgets/note_back_button.dart';

class ShareExternalNote extends StatefulWidget {
  final Map fullNoteData;

  const ShareExternalNote({
    super.key,
    required this.fullNoteData,
  });

  @override
  ShareExternalNoteState createState() => ShareExternalNoteState();
}

class ShareExternalNoteState extends State<ShareExternalNote>
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
                NoteBackButton(childPage: SharedNotesScreen()),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: GrantPermissionUi(
                    showAppBar: false,
                    fileName: widget.fullNoteData['sharedNoteInfo'][noteUrl],
                    isExternalRes: true,
                    externalWebId: widget.fullNoteData['sharedNoteInfo']
                        [noteOwner],
                    child: ShareExternalNote(
                      fullNoteData: widget.fullNoteData,
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
