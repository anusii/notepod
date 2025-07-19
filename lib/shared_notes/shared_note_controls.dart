/// DESCRIPTION
///
// Time-stamp: <Friday 2025-06-27 13:55:04 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
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
/// Authors: AUTHORS

library;

import 'package:flutter/material.dart';

import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/shared_notes/edit_shared_note.dart';
import 'package:notepod/shared_notes/share_external_note.dart';

ElevatedButton shareNote(
    BuildContext context, Map<dynamic, dynamic> fullNoteData) {
  return ElevatedButton.icon(
    icon: const Icon(
      Icons.share,
      color: Colors.white,
    ),
    onPressed: () {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => AppScreen(
                  title: topBarTitle,
                  childPage: ShareExternalNote(
                    noteMetaData: fullNoteData,
                  ),
                )),
        (Route<dynamic> route) =>
            false, // This predicate ensures all previous routes are removed
      );
    },
    style: ElevatedButton.styleFrom(
      foregroundColor: darkBlue,
      backgroundColor: lightBlue, // foreground
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    label: const Text(
      'SHARE',
      style: TextStyle(color: Colors.white),
    ),
  );
}

ElevatedButton editNote(
  BuildContext context,
  Map<dynamic, dynamic> fullNoteData,
) {
  return ElevatedButton.icon(
    icon: const Icon(
      Icons.edit,
      color: Colors.white,
    ),
    onPressed: () async {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => AppScreen(
                  childPage: EditSharedNote(
                    fullNoteData: fullNoteData,
                  ),
                )),
        (Route<dynamic> route) =>
            false, // This predicate ensures all previous routes are removed
      );
    },
    style: ElevatedButton.styleFrom(
      foregroundColor: darkGreen,
      backgroundColor: lightGreen, // foreground
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    label: const Text(
      'EDIT',
      style: TextStyle(color: Colors.white),
    ),
  );
}
