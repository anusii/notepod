/// The shared note button page.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Graham Williams, Anuska Vidanage, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/utils/nav_to_child.dart';
// import 'package:notepod/home.dart';

/// A stylised share button widget for notes. A simpler version
/// of the button is displayed with icon only if [showSimple] or
/// [isNarrow] is true.
///
/// Arguments:
/// - [childPage] - The child widget to navigate to.
/// - [showSimple] - Boolean describing whether to show
/// simple version of button without text label.
/// - [isNarrow] - Boolean describing whether displaying
/// in a narrow window.

class NoteShareButton extends StatelessWidget {
  /// Page to display on button click
  final Widget childPage;

  /// Show simple button without label
  final bool showSimple;

  /// Boolean describing whether window is narrow
  final bool isNarrow;

  const NoteShareButton({
    super.key,
    required this.childPage,
    this.showSimple = false,
    this.isNarrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return (showSimple || isNarrow)
        ? simpleShareButton(context)
        : shareButton(context);
  }

  /// A simple share button for using in note lists.

  Center simpleShareButton(BuildContext context) {
    return Center(
      child: Ink(
        decoration: buttonShapeList,
        child: IconButton(
          icon: const Icon(Icons.share),
          onPressed: () async {
            // Redirect.
            navToChildPage(context, childPage);
          },
        ),
      ),
    );
  }

  /// Elevated Share button with text label for using in note views.

  ElevatedButton shareButton(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color
      icon: Icon(
        Icons.share,
      ),
      onPressed: () async {
        // Redirect.
        navToChildPage(context, childPage);
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.share),
          ),
      label: Text(
        'SHARE',
      ),
    );
  }
}
