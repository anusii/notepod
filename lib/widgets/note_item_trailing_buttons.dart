/// A stateless widget to show trailing buttons in a note list item.
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

import 'package:solidui/solidui.dart';

import 'package:notepod/models/note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/share_note.dart';
import 'package:notepod/utils/get_id.dart';
import 'package:notepod/utils/misc.dart';
import 'package:notepod/widgets/simple_action_button.dart';

/// A [stateless] widget to show trailing buttons in a note
/// list item.
///
/// Arguments:
/// - [note] - A note.
/// - [scaffoldController] - Controller for the Solid scaffold.
///
class NoteItemTrailingButtons extends StatelessWidget {
  const NoteItemTrailingButtons({
    super.key,
    required Note note,
    required SolidScaffoldController scaffoldController,
  })  : _note = note,
        _scaffoldController = scaffoldController;

  final Note _note;
  final SolidScaffoldController _scaffoldController;

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
    List accessList = _note.permissionList.split(',');

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: [
        // Info button — leftmost, opens metadata dialog
        MarkdownTooltip(
          message: '**Note details**\n\nTap to view metadata for this note.',
          child: SimpleActionButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showMetadata(context),
          ),
        ),

        // Share button if control in permissions
        if (accessList.contains('control')) ...[
          MarkdownTooltip(
            message: '**Share note**\n\nTap to share this note.',
            child: SimpleActionButton(
              icon: const Icon(Icons.share),
              childPage: ShareNote(
                noteUrl: _note.noteUrl,
                noteOwner: _note.noteOwner,
                isExternal: _note.isExternalRes,
                backPage: ListNotesScreen(
                  scaffoldController: _scaffoldController,
                ),
                scaffoldController: _scaffoldController,
              ),
              scaffoldController: _scaffoldController,
            ),
          ),
        ],
        // Open note icon
        const Icon(Icons.arrow_forward),
      ],
    );
  }
}

class _Row {
  final String label;
  final String value;
  const _Row(this.label, this.value);
}
