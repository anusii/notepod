/// Login required dialog.
///
/// Copyright (C) 2026, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Friday 2025-10-03 13:56:10 +1100 Graham Williams>
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart' show SolidAuthHandler;

/// A dialog informing the user that they must log in to their POD before
/// continuing with the requested action.

class LoginRequiredDialog {
  /// Shows the `Login Required` dialog and returns `true` when the user
  /// chooses to log in, or `false` (including dismissals) otherwise.

  static Future<bool> show(
    BuildContext context, {
    String message = 'Please log in to your POD first before saving the note.',
  }) async {
    final theme = Theme.of(context);

    final shouldLogin = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Login Required',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log In', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    return shouldLogin ?? false;
  }

  /// Convenience helper that displays the dialog and, when the user opts
  /// to log in, delegates to [SolidAuthHandler] to start the standard
  /// login flow. If the user cancels nothing further happens, leaving
  /// them on the calling screen (e.g. the note editor).

  static Future<void> showAndHandle(
    BuildContext context, {
    String message = 'Please log in to your POD first before saving the note.',
  }) async {
    final shouldLogin = await show(context, message: message);
    if (shouldLogin && context.mounted) {
      await SolidAuthHandler.instance.handleLogin(context);
    }
  }
}
