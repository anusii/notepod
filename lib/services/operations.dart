/// Common checks
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Thursday 2025-10-02 12:53:12 +1100 Graham Williams>
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

mixin PodOperationsMixin {
  /// Validates that the context is still mounted.
  /// Returns true if valid, false otherwise.

  bool validateContext(BuildContext context) {
    if (!context.mounted) {
      return false;
    }
    return true;
  }

  /// Checks if an error indicates a file doesn't exist.

  bool isFileNotFoundError(Object error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('does not exist') ||
        errorStr.contains('404') ||
        errorStr.contains('not found');
  }

  /// Checks if an error is related to permissions.

  bool isPermissionError(Object error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('permission') ||
        errorStr.contains('auth') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('forbidden') ||
        errorStr.contains('403');
  }

  /// Checks if an error is related to network issues.

  bool isNetworkError(Object error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('timeout') ||
        errorStr.contains('socket');
  }
}
