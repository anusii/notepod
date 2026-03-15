/// UI constants.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Wednesday 2025-10-07 12:52:23 +1100 Graham Williams>
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

import 'package:solidui/solidui.dart' show WindowSize;

/// Approximate size for grid items used for
/// displaying text of user's notes.

class NoteItemSize {
  /// Approximate height of compressed item
  /// in user's own notes list
  /// when list item text is line wrapped
  /// in a narrow mobile phone size window.
  /// (Where each of note title, created date time,
  /// modified date time are line wrapped to
  /// two lines.)

  static const double compressedOwnItemHeight =
      260; // (4 row subtitle) 190; (3 row subtitle)

  /// Approximate height of uncompressed item
  /// in user's own notes list
  /// when list item text is not line wrapped.

  static const double uncompressedOwnItemHeight =
      138; // (4 row subtitle) 108; (3 row subtitle)

  /// Approximate height of compressed item
  /// in user's external notes list
  /// when list item text is line wrapped
  /// in a narrow mobile phone size window.
  /// (Where each of note title, created date time,
  /// modified date time are line wrapped to
  /// two lines.)

  // static const double compressedExtItemHeight = 260; // (4 row subtitle)
  static const double compressedExtItemHeight = 390; // (6 row subtitle)

  /// Approximate height of uncompressed item
  /// in user's external notes list
  /// when list item text is not line wrapped.

  static const double uncompressedExtItemHeight = 207; // (6 row subtitle)

  /// Calculate card aspect ratio to use for
  /// gridview builder cards using the box
  /// constraints found by LayoutBuilder().
  ///
  /// Arguments:
  /// - [constraints] - The box constraints of the parent widget
  /// where LayoutBuilder() called.
  double calculateCardAspectRatio(BoxConstraints constraints) {
    /// Aspect ratio (width / height) for gridview
    /// cards to display note items
    final double cardAspectRatio;

    /// Compressed item height
    final double compressedItemHeight;

    /// Uncompressed item height
    final double uncompressedItemHeight;

    // Use appropriate item heights
    compressedItemHeight = compressedExtItemHeight;
    uncompressedItemHeight = uncompressedExtItemHeight;

    // Derive card aspect ratio (width / height)
    if (constraints.maxWidth < WindowSize.smallWidthLimit) {
      cardAspectRatio = constraints.maxWidth / compressedItemHeight;
    } else {
      cardAspectRatio = constraints.maxWidth / uncompressedItemHeight;
    }
    return cardAspectRatio;
  }
}

/// Button labels

class ButtonLabel {
  /// Share button label
  static const String share = 'SHARE';

  /// Back button label
  static const String back = 'BACK';

  /// Edit button label
  static const String edit = 'EDIT';

  /// Delete button label
  static const String delete = 'DELETE';

  /// Revoke button label
  static const String revoke = 'REVOKE';

  /// Save button label
  static const String save = 'SAVE';

  /// Yes button label
  static const String yes = 'Yes';

  /// No button label
  static const String no = 'No';
}
