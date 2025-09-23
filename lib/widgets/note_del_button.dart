/// The edit note page.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:32:47 +1100 Graham Williams>
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
/// Authors: Jess Moore
library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/home.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/widgets/loading_animation.dart';

/// A stylised delete button widget for notes.

class NoteDelButton extends StatelessWidget {
  final Map noteData;
  final bool shared;

  const NoteDelButton({
    super.key,
    required this.noteData,
    required this.shared,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text(Msg.plsConfirm),
              content: const Text(
                Msg.confirmDelete,
              ),
              actions: [
                // The "Yes" button
                TextButton(
                  onPressed: () async {
                    showAnimationDialog(
                      context,
                      17,
                      Msg.deletingNote,
                      false,
                    );

                    // Delete file
                    if (shared) {
                      await deleteExternalFile(noteData[noteUrl]);
                    } else {
                      // Create note file path
                      String noteFilePath =
                          '$mainResDir/$dataDir/$noteFileNamePrefix${noteData[createdDateTimePred]}.ttl';

                      // Call solid delete file function
                      await deleteFile(noteFilePath);
                    }

                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppHomePage(
                            title: topBarTitle,
                            childPage: ListNotesScreen(),
                          ),
                        ),
                        (Route<dynamic> route) =>
                            false, // This predicate ensures all previous routes are removed
                      );
                    }
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: darkRed,
        backgroundColor: lightRed, // foreground
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      label: const Text(
        'DELETE',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
