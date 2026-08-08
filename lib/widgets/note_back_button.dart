/// A stylised back button widget.
///
// Time-stamp: <Wednesday 2025-07-16 09:08:27 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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
/// Authors: Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:notepod/constants/colours.dart';

/// A stylised back button widget for notes. On click it checks if edited data exists, if found it asks if the user wants to save or not save or cancel the back action. Then it navigates to the provided child page.
///
/// Arguments:
/// - [childPage] - The child page to navigate back to.
///   [scaffoldController] - Controller for the Solid scaffold.
/// - [hasChanges] - Optional boolean denoting whether the editor holds
/// unsaved edits. (Default: false, for the plain back buttons that sit on
/// screens with nothing to lose).
/// - [onSave] - Optional callback writing the note to the Pod, reporting
/// whether the write landed. Required when [hasChanges] can be
/// true. (Default: null).

class NoteBackButton extends StatelessWidget {
  const NoteBackButton({
    super.key,
    required this.childPage,
    required this.scaffoldController,
    this.hasChanges = false,
    this.onSave,
  });

  final Widget childPage;
  final SolidScaffoldController scaffoldController;
  final bool hasChanges;
  final Future<bool> Function()? onSave;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color
      icon: const Icon(
        Icons.keyboard_backspace,
      ),
      onPressed: () async {
        if (!hasChanges) {
          debugPrint('No unsaved changes found');
          scaffoldController.navigateToSubpage(childPage);
          return;
        }
        // The same prompt the desktop window-close guard raises, so leaving
        // by Back and leaving by closing the window read the same.
        final action = await showUnsavedChangesDialog(context);
        if (!context.mounted) return;
        switch (action) {
          case UnsavedChangesAction.save:
            // The save itself navigates on to the saved note.
            await onSave?.call();
          case UnsavedChangesAction.discard:
            scaffoldController.navigateToSubpage(childPage);
          case UnsavedChangesAction.keepEditing:
            break;
        }
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.back),
          ),
      label: const Text(
        'BACK',
      ),
    );
  }
}
