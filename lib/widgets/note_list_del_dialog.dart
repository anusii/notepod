/// A dialog for deleting corrupt files.
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

import 'package:notepod/constants/app.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_list_del_button.dart';

/// A page listing corrupted note files with button to delete
/// all files in the list.
///
/// Arguments:
/// - [badFiles] - list of filenames of corrupted files.
/// - [childPage] - child widget to return to.

class NotesDelDialog extends StatefulWidget {
  final List<String> badFiles;
  final Widget childPage;

  const NotesDelDialog({
    super.key,
    required this.badFiles,
    required this.childPage,
  });

  @override
  State<NotesDelDialog> createState() => _NotesDelDialogState();
}

class _NotesDelDialogState extends State<NotesDelDialog> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.badFiles.length > 1
                      ? 'Found ${widget.badFiles.length} corrupt notes'
                      : 'Found ${widget.badFiles.length} corrupt note',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // List of corrupted notes
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: widget.badFiles.length,
                itemExtent: badListItemHeight,
                itemBuilder: (context, index) => Card(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: ListTile(
                      title: Text(
                        'Filename: ${widget.badFiles[index]}',
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
              children: [
                /// Note list delete button
                NoteListDelButton(
                  badFiles: widget.badFiles,
                  childPage: widget.childPage,
                ),
                const SizedBox(
                  width: 5,
                ),
                // Back button
                NoteBackButton(childPage: widget.childPage),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
