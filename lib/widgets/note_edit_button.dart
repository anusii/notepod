/// The edit note page.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2025-07-18 20:34:12 +1100 Jess Moore>
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
library;

import 'package:flutter/material.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/home.dart';

/// A stylised edit button widget for notes.

class NoteEditButton extends StatelessWidget {
  final Widget childPage;

  const NoteEditButton({
    super.key,
    required this.childPage,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color
      icon: const Icon(
        Icons.edit,
      ),
      onPressed: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AppHomePage(
              title: topBarTitle,
              childPage: childPage,
            ),
          ),
          (Route<dynamic> route) =>
              false, // This predicate ensures all previous routes are removed
        );
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.edit),
          ),
      label: const Text(
        'EDIT',
      ),
    );
  }
}
