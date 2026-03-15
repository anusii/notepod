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
import 'package:notepod/utils/get_id.dart';
import 'package:notepod/utils/misc.dart';

/// A [stateless] widget to show subtitle of a note list item.
/// It shows the number of recipients that the note is shared
/// with if note owned by user, or entity that share it if
/// owned by another, and does not show encrypted content if
/// read access denied.
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
  final bool _isNarrow;

  @override
  Widget build(BuildContext context) {
    return Text(
      (!_note.isExternalRes)
          ? 'Filename: ${_note.noteFileName} \n'
              'Created on: ${getDateTimeStr(_note.content!.createdDateTime)} \n'
              'Last modified: ${getDateTimeStr(_note.content!.modifiedDateTime)}\n'
              'Owner: ${getId(_note.noteOwner)} \n'
              'Shared with: ${getRecipNbrStr(_note.authUserList!.keys.length)} \n'
              'Permissions: ${_note.permissionList}'
          : (_note.permissionList.contains('read'))
              ? 'Filename: ${_note.noteFileName} \n'
                  'Created on: ${getDateTimeStr(_note.content!.createdDateTime)} \n'
                  'Last modified: ${getDateTimeStr(_note.content!.modifiedDateTime)}\n'
                  'Owner: ${getId(_note.noteOwner)} \n'
                  'Shared by: ${getId(_note.permissionGranter ?? 'N/A')} \n'
                  'Permissions: ${_note.permissionList}'
              : 'Filename: ${_note.noteFileName} \n'
                  'Owner: ${getId(_note.noteOwner)} \n'
                  'Shared by: ${getId(_note.permissionGranter ?? 'N/A')} \n'
                  'Permissions: ${_note.permissionList}',
      maxLines: (!_isNarrow) ? 6 : 12, // Limit lines
      overflow: TextOverflow.ellipsis,
    );
  }
}
