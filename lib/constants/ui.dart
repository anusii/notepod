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

/// Thresholds for window size
class WindowSize {
  /// Small width threshold
  static const double smallWidthLimit = 600;

  /// Small height threshold
  static const double smallHeightLimit = 600;

  /// Boolean describing whether the parent widget
  /// is narrow. Derived from the box constraints
  /// found by LayoutBuilder().
  ///
  /// Arguments:
  /// - [constraints] - The box constraints of the parent widget where LayoutBuilder() called.
  bool isNarrowWindow(BoxConstraints constraints) {
    final bool isNarrow;
    if (constraints.maxWidth < WindowSize.smallWidthLimit) {
      isNarrow = true;
    } else {
      isNarrow = false;
    }

    return isNarrow;
  }
}

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

  static const double compressedOwnItemHeight = 190;

  /// Approximate height of uncompressed item
  /// in user's own notes list
  /// when list item text is not line wrapped.

  static const double uncompressedOwnItemHeight = 108;

  /// Approximate height of compressed item
  /// in user's external notes list
  /// when list item text is line wrapped
  /// in a narrow mobile phone size window.
  /// (Where each of note title, created date time,
  /// modified date time are line wrapped to
  /// two lines.)

  static const double compressedExtItemHeight = 250;

  /// Approximate height of uncompressed item
  /// in user's external notes list
  /// when list item text is not line wrapped.

  static const double uncompressedExtItemHeight = 138;

  /// Calculate card aspect ratio to use for
  /// gridview builder cards using the box
  /// constraints found by LayoutBuilder().
  ///
  /// Arguments:
  /// - [constraints] - The box constraints of the parent widget
  /// where LayoutBuilder() called.
  /// - [isExternal] - Boolean describing whether its an external
  /// note which has more rows of text.
  double calculateCardAspectRatio(BoxConstraints constraints, bool isExternal) {
    /// Aspect ratio (width / height) for gridview
    /// cards to display note items
    final double cardAspectRatio;

    /// Compressed item height
    final double compressedItemHeight;

    /// Uncompressed item height
    final double uncompressedItemHeight;

    // Use appropriate item heights
    if (!isExternal) {
      compressedItemHeight = compressedOwnItemHeight;
      uncompressedItemHeight = uncompressedOwnItemHeight;
    } else {
      compressedItemHeight = compressedExtItemHeight;
      uncompressedItemHeight = uncompressedExtItemHeight;
    }

    // Derive card aspect ratio (width / height)
    if (constraints.maxWidth < WindowSize.smallWidthLimit) {
      cardAspectRatio = constraints.maxWidth / compressedItemHeight;
    } else {
      cardAspectRatio = constraints.maxWidth / uncompressedItemHeight;
    }
    return cardAspectRatio;
  }
}
