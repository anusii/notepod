/// The save note button.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Wednesday 2025-07-16 08:32:47 +1100 Jess Moore>
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

import 'package:notepod/constants/colours.dart';

/// A stylised save button widget which on click saves the note content
/// Pod. External notes are written to the note owner's Pod. Notes created
/// by the user are written to the user's Pod.
///
/// Examples
/// - `NoteSaveButton(onSave: _save, enabled: _hasChanges)` save the metadata
/// and content of the note the editor is holding.
///
/// - [onSave] - Writes the note to the Pod. Supplied by the editor, which
/// knows whether this is a new or an existing note. Awaited, so that closing
/// the window can wait for the write rather than killing it mid-flight.
/// Reports whether the write landed; a failure has already been shown to the
/// user by the save itself, so there is nothing more to do here.
/// - [enabled] - Optional boolean denoting whether there is anything worth
/// saving. (Default: true).

class NoteSaveButton extends StatelessWidget {
  final Future<bool> Function() onSave;
  final bool enabled;

  const NoteSaveButton({
    super.key,
    required this.onSave,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color and padding
      icon: const Icon(
        Icons.save,
      ),
      onPressed: enabled
          ? () async {
              // Save note and redirect to view note page
              await onSave();
            }
          : null,
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.save),
            // Larger edgeinsets to emphasise save button
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
      label: const Text(
        'SAVE',
      ),
    );
  }
}
