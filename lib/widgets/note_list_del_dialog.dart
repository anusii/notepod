/// A dialog for deleting unparseable files.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Monday 2025-10-06 16:03:04 +1100 Graham Williams>
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

import 'package:communitypod/constants/app.dart';
import 'package:communitypod/constants/ui.dart';
import 'package:communitypod/models/selected_note.dart';
import 'package:communitypod/widgets/note_back_button.dart';
import 'package:communitypod/widgets/note_list_del_button.dart';

/// A page listing unparseable note files with button to delete
/// all files in the list.
///
/// Arguments:
/// - [unparseableNotes] - list of unparseable notes.
/// - [childPage] - child widget to navigate to after delete dialog.
///   [scaffoldController] - Controller for the Solid scaffold.
/// - [isExternal] - flag describing whether files are externally owned.

class NotesDelDialog extends StatefulWidget {
  final List<SelectedNote> unparseableNotes;

  /// Childpage to navigate to after delete dialog
  final Widget childPage;

  /// Scaffold controller
  final SolidScaffoldController scaffoldController;

  /// Boolean describing whether note is external
  final bool isExternal;

  const NotesDelDialog({
    super.key,
    required this.unparseableNotes,
    required this.childPage,
    required this.scaffoldController,
    this.isExternal = false,
  });

  @override
  State<NotesDelDialog> createState() => _NotesDelDialogState();
}

class _NotesDelDialogState extends State<NotesDelDialog> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Aspect ratio (width / height) for gridview
  /// cards to display note items
  late double cardAspectRatio = 2.0;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

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
        cardAspectRatio = NoteItemSize().calculateCardAspectRatio(constraints);
        return SizedBox(
          child: Column(
            children: [
              // Title and count of corrupted notes
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
                          NoteListMsg.badFilesFound,
                          style: titleStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.unparseableNotes.length > 1
                          ? 'Found ${widget.unparseableNotes.length} unparseable notes'
                          : 'Found ${widget.unparseableNotes.length} unparseable note',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // List of unparseable notes
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: widget.unparseableNotes.length,
                    itemExtent: badListItemHeight,
                    itemBuilder: (context, index) => Card(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: ListTile(
                          title: Text(
                            'Filename: ${widget.unparseableNotes[index].noteFileName}',
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
                    /// Note list delete button
                    NoteListDelButton(
                      selectedNotes: widget.unparseableNotes,
                      childPage: widget.childPage,
                      scaffoldController: _scaffoldController,
                      isExternal: widget.isExternal,
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
