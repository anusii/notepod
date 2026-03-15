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

import 'package:solidui/solidui.dart';

import 'package:communitypod/models/note.dart';
import 'package:communitypod/notes/list_notes_screen.dart';
import 'package:communitypod/notes/share_note.dart';
import 'package:communitypod/widgets/simple_action_button.dart';

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

  @override
  Widget build(BuildContext context) {
    List accessList = _note.permissionList.split(',');

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 10.0,
      children: [
        // Share button if control in permissions
        if (accessList.contains('control')) ...[
          SimpleActionButton(
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
        ],
        // Open note icon
        // Launch icon to denote expanding to full size
        // Alternative open_in_full_rounded
        const Icon(Icons.launch_rounded),
      ],
    );
  }
}
