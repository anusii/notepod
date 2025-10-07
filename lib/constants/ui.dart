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

class OwnNoteItemSize {
  /// Approximate height of compressed item
  /// when list item text is line wrapped
  /// in a narrow mobile phone size window.
  /// (Where each of note title, created date time,
  /// modified date time are line wrapped to
  /// two lines.)

  static const double compressedItemHeight = 190;

  /// Approximate height of uncompressed item
  /// when list item text is not line wrapped.

  static const double uncompressedItemHeight = 108;

  /// Calculate card aspect ratio using the box
  /// constraints found by LayoutBuilder().
  ///
  /// Arguments:
  /// - [_constraints] - The box constraints of the parent widget where LayoutBuilder() called.
  double calculateCardAspectRatio(BoxConstraints constraints) {
    // TODO: constraints of parent widget available

    /// Aspect ratio (width / height) for gridview
    /// cards to display note items
    final double cardAspectRatio;

    debugPrint(
      'Contraints: ${constraints.toString()}',
    );
    debugPrint('max height: ${constraints.maxHeight}');
    debugPrint('max width: ${constraints.maxWidth}');
    if (constraints.maxWidth < WindowSize.smallWidthLimit) {
      cardAspectRatio =
          constraints.maxWidth / OwnNoteItemSize.compressedItemHeight;
    } else {
      cardAspectRatio =
          constraints.maxWidth / OwnNoteItemSize.uncompressedItemHeight;
    }
    return cardAspectRatio;
  }
}
