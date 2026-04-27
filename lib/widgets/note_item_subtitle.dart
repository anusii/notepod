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

import 'package:markdown_tooltip/markdown_tooltip.dart';

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

  // ignore: unused_field
  final bool _isNarrow;

  void _showMetadata(BuildContext context) {
    final n = _note;
    final rows = <_Row>[];

    rows.add(_Row('File', n.noteFileName));
    if (n.content != null) {
      rows.add(_Row('Created', getDateTimeStr(n.content!.createdDateTime)));
      rows.add(_Row('Modified', getDateTimeStr(n.content!.modifiedDateTime)));
    }
    rows.add(_Row('Owner', getId(n.noteOwner)));
    if (!n.isExternalRes && n.authUserList != null) {
      rows.add(
        _Row('Shared with', getRecipNbrStr(n.authUserList!.keys.length)),
      );
    }
    if (n.isExternalRes) {
      rows.add(_Row('Shared by', getId(n.permissionGranter ?? 'N/A')));
    }
    rows.add(_Row('Permissions', n.permissionList));

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          n.content?.noteTitle ?? n.noteFileName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: rows.map((r) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 16, 4),
                      child: Text(
                        r.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(r.value),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final modified = _note.content != null
        ? getDateTimeStr(_note.content!.modifiedDateTime)
        : '';
    return Row(
      children: [
        if (modified.isNotEmpty)
          Expanded(
            child: Text(
              modified,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        MarkdownTooltip(
          message: '**Note details**\n\nTap to view metadata for this note.',
          child: IconButton(
            icon: Icon(
              Icons.info_outline,
              size: 16,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showMetadata(context),
          ),
        ),
      ],
    );
  }
}

class _Row {
  final String label;
  final String value;
  const _Row(this.label, this.value);
}
