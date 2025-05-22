/// The home page for the app.
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
/// Authors: Anushka Vidanage

library;

import 'package:flutter/material.dart';
import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/app_screen.dart';

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
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.keyboard_backspace,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AppScreen(
                                title: topBarTitle,
                                childPage: ViewNote(noteData: widget.noteData),
                              )),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: titleAsh,
                    backgroundColor: lightGray, // foreground
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  label: const Text(
                    'GO BACK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
