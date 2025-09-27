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

library;

import 'package:flutter/material.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/home.dart';

/// A stylised share button widget for notes.

class NoteShareButton extends StatelessWidget {
  /// Page to display on button click
  final Widget childPage;

  /// Simple button style option.
  ///
  /// Used to specify a simpler style without label for use when
  /// less real estate is available.Default false (full button with label)
  final bool? simple;

  /// isSelected note status option.
  ///
  /// Used to specify whether this button should adopt the
  /// style of a selected note in a note list
  final bool isSelected;

  const NoteShareButton({
    super.key,
    required this.childPage,
    this.simple = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return simple! ? simpleShareButton(context) : shareButton(context);
  }

  /// A simple share button for using in note lists.

  Center simpleShareButton(BuildContext context) {
    return Center(
      child: Ink(
        decoration: buttonShapeList,
        child: IconButton(
          icon: const Icon(Icons.share),
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).iconTheme.color,
          onPressed: () async {
            // Redirect.
            navToChildPage(context);
          },
        ),
      ),
    );
  }

  /// Elevated Share button with text label for using in note views.

  ElevatedButton shareButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(
        Icons.share,
        color: Theme.of(context).iconTheme.color,
      ),
      onPressed: () async {
        // Redirect.
        navToChildPage(context);
      },
      style: buttonStyleView,
      label: Text(
        'SHARE',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  /// Navigate to sharing child page.

  dynamic navToChildPage(BuildContext context) async {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => AppHomePage(
          title: topBarTitle,
          childPage: childPage,
        ),
      ),
      (Route<dynamic> route) =>
          // Ensure all previous routes are removed.
          false,
    );
  }
}
