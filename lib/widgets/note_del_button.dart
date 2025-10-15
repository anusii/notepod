/// The delete note button.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Jess Moore
library;

import 'package:flutter/material.dart';

import 'package:notepod/common/rest_api/file_helper.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/utils/nav_to_child.dart';
import 'package:notepod/widgets/loading_animation.dart';

/// A stylised delete button widget for notes. A simpler version
/// of the button is displayed with icon only if [simple] or
/// [isNarrow] is true.
///
/// Arguments:
/// - [filename] - Filename of note.
/// - [childPage] - The child widget to navigate to.
/// - [isExternal] - Boolean describing whether an external note.
/// - [showSimple] - Boolean describing whether to show
/// simple version of button without text label.
/// - [isNarrow] - Boolean describing whether displaying
/// in a narrow window.

class NoteDelButton extends StatelessWidget {
  final String filename;

  /// Childpage
  final Widget childPage;

  /// Boolean describing whether an external note
  final bool isExternal;

  /// Show simple button without label
  final bool showSimple;

  /// Boolean describing whether window is narrow
  final bool isNarrow;

  const NoteDelButton({
    super.key,
    required this.filename,
    required this.childPage,
    this.isExternal = false,
    this.showSimple = false,
    this.isNarrow = false,
  });

  /// Delete note dialog
  void noteDelDialog(BuildContext context) {
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
                  Msg.deletingNote,
                  false,
                );

                // Delete file
                await NoteFileHelper()
                    .deleteNote(context, filename, isExternal);

                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true)
                      .pop(); // Dismiss the deleting note dialog

                  navToChildPage(context, childPage);
                }
              },
              child: const Text(ButtonLabel.yes),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(); // Dismiss the deleting note dialog
              },
              child: const Text(ButtonLabel.no),
            ),
          ],
        );
      },
    );
  }

  /// Simple delete button

  Center simpleDelButton(BuildContext context) {
    return Center(
      child: Ink(
        decoration: const ShapeDecoration(
          color: ButtonBackgroundColor.delete,
          shape: CircleBorder(),
        ),
        child: IconButton(
          color: ButtonForegroundColor.view,
          icon: const Icon(
            Icons.delete,
          ),
          onPressed: () {
            // Display note confirm delete dialog
            noteDelDialog(context);
          },
        ),
      ),
    );
  }

  /// Full size delete button

  ElevatedButton fullSizeDelButton(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color
      icon: const Icon(
        Icons.delete,
      ),
      onPressed: () {
        // Display note confirm delete dialog
        noteDelDialog(context);
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.delete),
          ),
      label: const Text(
        ButtonLabel.delete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (showSimple || isNarrow)
        ? simpleDelButton(context)
        : fullSizeDelButton(context);
  }
}
