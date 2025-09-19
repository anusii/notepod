/// Navigation Drawer for notepod.
///
/// Copyright (C) 2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2025-09-18 08:53:10 +1000 Jess Moore>
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
/// Authors: Anushka Vidanage, Jess Moore
library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/home.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/new_note.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';

SolidAppBarConfig navAppBar(BuildContext context) {
  return SolidAppBarConfig(
    title: topBarTitle,
    backgroundColor: lightGreen,
    versionConfig: SolidVersionConfig(
      changelogUrl: appChangeLog,
      showDate: true,
      tooltip: 'Custom version tooltip',
    ),
    actions: [
      // Create new note
      SolidAppBarAction(
        tooltip: 'Create a new note',
        icon: Icons.add_circle,
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AppHomePage(
                childPage: NewNote(),
              ),
            ),
            (Route<dynamic> route) =>
                false, // This predicate ensures all previous routes are removed
          );
        },
      ),
      // List notes
      SolidAppBarAction(
        tooltip: 'Go to $myNotesTitle',
        icon: Icons.view_list,
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AppHomePage(
                childPage: ListNotesScreen(),
              ),
            ),
            (Route<dynamic> route) =>
                false, // This predicate ensures all previous routes are removed
          );
        },
      ),
      // List shared notes
      SolidAppBarAction(
        tooltip: 'Go to $sharedNotesTitle',
        icon: Icons.groups,
        // Also tried (20250718 gjw)
        // Icons.people,
        // Icons.share,
        // Icons.group,
        // Icons.supervisor_account,
        // Icons.share_rounded,
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AppHomePage(
                childPage: SharedNotesScreen(),
              ),
            ),
            (Route<dynamic> route) =>
                false, // This predicate ensures all previous routes are removed
          );
        },
      ),
    ],
  );
}
