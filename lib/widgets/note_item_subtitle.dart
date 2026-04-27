/// A stateless widget to show subtitle of a note list item.
///
/// Copyright (C) 2026 Software Innovation Institute, Australian National University
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://opensource.org/license/gpl-3-0
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

import 'package:notepod/models/note.dart';
import 'package:notepod/utils/misc.dart';

/// A [stateless] widget to show subtitle of a note list item.
/// Shows the last modified date, or nothing if unavailable.
///
/// Arguments:
/// - [note] - A note.
/// - [isNarrow] - Flag describing whether window is narrower than
/// narrow threshold.
///
class NoteItemSubtitle extends StatelessWidget {
  const NoteItemSubtitle({
    super.key,
    required Note note,
    required bool isNarrow,
  })  : _note = note,
        _isNarrow = isNarrow;

  final Note _note;

  // ignore: unused_field
  final bool _isNarrow;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final modified = _note.content != null
        ? getDateTimeStr(_note.content!.modifiedDateTime)
        : '';
    if (modified.isEmpty) return const SizedBox.shrink();
    return Text(
      modified,
      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
      overflow: TextOverflow.ellipsis,
    );
  }
}
