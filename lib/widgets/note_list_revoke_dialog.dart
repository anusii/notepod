/// A dialog for revoking access to any deleted external files.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Sunday 2025-11-02 17:03:04 +1100 Graham Williams>
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

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/models/external_note.dart';
import 'package:notepod/utils/get_id.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_list_revoke_button.dart';

/// A page listing external note file records which no longer
/// exist with button to update permission log with 'revoke'
/// record for all files in the list.
///
/// Arguments:
/// - [nonExistentNotes] - note list of non-existent files.
/// - [childPage] - child widget to return to.
/// - [scaffoldController] - Controller for the Solid scaffold.

class NotesRevokeDialog extends StatefulWidget {
  final List<ExternalNote> nonExistentNotes;
  final Widget childPage;

  /// Scaffold controller
  final SolidScaffoldController scaffoldController;

  const NotesRevokeDialog({
    super.key,
    required this.nonExistentNotes,
    required this.childPage,
    required this.scaffoldController,
  });

  @override
  State<NotesRevokeDialog> createState() => _NotesRevokeDialogState();
}

class _NotesRevokeDialogState extends State<NotesRevokeDialog> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Aspect ratio (width / height) for gridview
  /// cards to display note items
  late double cardAspectRatio = 2.0;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  /// Boolean describing whether note is external
  final bool isExternal = true;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scaffoldController = widget.scaffoldController;
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Derive whether window is narrow
        isNarrow = WindowSize().isNarrowWindow(constraints);
        // Calculate the aspect radio for grid cards
        cardAspectRatio =
            NoteItemSize().calculateCardAspectRatio(constraints, isExternal);
        return SizedBox(
          child: Column(
            children: [
              // Title and count of non existent notes
              Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.error,
                            color: Colors.amber,
                            size: 60,
                          ),
                        ),
                      ],
                    ), //CircleAvatar
                    const SizedBox(
                      height: 30,
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          NoteListMsg.nonExistentNotesFound,
                          style: titleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Press \'Revoke\' to update log record',
                      style: adviceStyle,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      widget.nonExistentNotes.length > 1
                          ? 'Found ${widget.nonExistentNotes.length} non-existent notes'
                          : 'Found ${widget.nonExistentNotes.length} non-existent note',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // List of non existent notes
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      // Aspect ratio calculated from LayoutBuilder box constraints
                      crossAxisCount: 1,
                      childAspectRatio: cardAspectRatio,
                    ),
                    padding: const EdgeInsets.all(10),
                    itemCount: widget.nonExistentNotes.length,
                    itemBuilder: (context, index) => Card(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: ListTile(
                          title: Text(
                            'Note Url: ${widget.nonExistentNotes[index].noteUrl}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Owner: ${getId(widget.nonExistentNotes[index].noteOwner)} \nShared by: ${getId(widget.nonExistentNotes[index].permissionGranter)} \nPermissions: ${widget.nonExistentNotes[index].permissionList}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Define width to avoid consuming full width
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 5.0,
                  children: [
                    // Note list revoke button
                    NoteListRevokeButton(
                      nonExistentNotes: widget.nonExistentNotes,
                      childPage: widget.childPage,
                      scaffoldController: _scaffoldController,
                    ),
                    // Back button
                    NoteBackButton(
                      childPage: widget.childPage,
                      scaffoldController: _scaffoldController,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      },
    );
  }
}
