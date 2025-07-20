/// The shared note button page.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2025-07-19 13:13:12 +1100 Jess Moore>
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
/// Authors: Graham Williams, Anuska Vidanage, Jess Moore

import 'package:flutter/material.dart';

import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';

/// A stylised share button widget for notes.

class NoteShareButton extends StatelessWidget {
  final Widget childPage;

  const NoteShareButton({
    Key? key,
    required this.childPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(
        Icons.share,
        color: Colors.white,
      ),
      onPressed: () async {
        // redirect
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => AppScreen(
                    title: topBarTitle,
                    childPage: childPage,
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
}
