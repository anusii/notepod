/// List user's own notes.
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
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
/// Authors: Anushka Vidanage, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/models/own_note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/share_note.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/utils/misc.dart';
import 'package:notepod/utils/nav_to_child.dart';
import 'package:notepod/widgets/simple_action_button.dart';

/// A [StatefulWidget] to list notes owned by the user.
/// Parameters:
///   [notes] - is the file list map with data of all notes
///                in the user's app data folder (required to
///                display sharing information and support
///                sharing with suggestion list of recipient WebIds).
class ListNotes extends StatefulWidget {
  final List<OwnNote> notes;

  const ListNotes({
    super.key,
    required this.notes,
  });

  @override
  State<ListNotes> createState() => _ListNotesState();
}

class _ListNotesState extends State<ListNotes> {
  /// Searched/sorted notes
  List<FoundOwnNote> _foundNotes = [];

  // Sort order
  // true: ascending (A-Z), false: descending (Z-A)
  // Initial sort will sort alphabetically
  bool _sortTitleAscending = true;
  // true: ascending (oldest modified note), false: descending (last modified note)
  // First button press will change to sort by last modified first
  bool _sortModDateAscending = true;

  /// Current note sort method
  /// Initialised to sort by title
  String currSortMethod = '';

  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Count of selected notes
  int selectedCount = 0;

  /// Aspect ratio (width / height) for gridview
  /// cards to display note items
  late double cardAspectRatio = 2.0;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  /// Boolean describing whether note is external
  final bool isExternal = false;

  /// Update selected status and count of selected
  void updateSelected(int index) {
    setState(() {
      // Increment/decrement selected count
      if (_foundNotes[index].isSelected) {
        selectedCount--;
      } else {
        selectedCount++;
      }
      // Swap selected status of file
      _foundNotes[index].isSelected = !_foundNotes[index].isSelected;
    });
  }

  @override
  void initState() {
    super.initState();

    // By default _foundNotes is the full list of notes
    _foundNotes = widget.notes.toListFoundOwnNote();

    // Initial sort by title alphabetically
    _sortByTitle(_sortTitleAscending);

    // Initialise sorting method
    currSortMethod = 'sortByTitle';

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  // Sort alphanumerically on note title field
  void _sortByTitle(bool ascending) {
    setState(() {
      _sortTitleAscending = ascending;
      _foundNotes.sort(
        (a, b) => _sortTitleAscending
            ? a.content.noteTitle
                .toLowerCase()
                .compareTo(b.content.noteTitle.toLowerCase())
            : b.content.noteTitle
                .toLowerCase()
                .compareTo(a.content.noteTitle.toLowerCase()),
      );

      // Update current sort method
      currSortMethod = 'sortByTitle';
    });
  }

  // Sort numerically on note modified date field
  void _sortByModDate(bool ascending) {
    setState(() {
      _sortModDateAscending = ascending;
      _foundNotes.sort(
        (a, b) => _sortModDateAscending
            ? a.content.modifiedDateTime
                .toLowerCase()
                .compareTo(b.content.modifiedDateTime.toLowerCase())
            : b.content.modifiedDateTime
                .toLowerCase()
                .compareTo(a.content.modifiedDateTime.toLowerCase()),
      );

      // Update current sort method
      currSortMethod = 'sortByModDate';
    });
  }

  // Search notes
  void _searchNotes(String enteredKeyword) {
    List<FoundOwnNote> results = [];
    if (enteredKeyword.isEmpty) {
      // Display all notes if no search string
      results = widget.notes.toListFoundOwnNote();
    } else {
      // Display notes with title or contents containing search string
      results = widget.notes.toListFoundOwnNote().where((note) {
        return note.content.noteTitle
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            note.content.noteContent
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase());
      }).toList();
    }

    // Refresh the UI
    setState(() {
      _foundNotes = results;
    });

    // Sort by current sort method and polarity
    switch (currSortMethod) {
      case 'sortByTitle':
        _sortByTitle(_sortTitleAscending);
      case 'sortByModDate':
        _sortByModDate(_sortModDateAscending);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reduce calls to of(context).
    final theme = Theme.of(context);

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
              Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '$myNotesTitle (created by me)',
                      style: titleStyle,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (value) => _searchNotes(value),
                      decoration: const InputDecoration(
                        labelText: 'Search title or text',
                        hintText: 'Enter string to match note contents',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Count statement
                        // Match color scheme of sorting TextButtons
                        selectedCount > 0
                            ? Text(
                                'Selected: $selectedCount notes',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : _foundNotes.length > 1 || _foundNotes.isEmpty
                                ? Text(
                                    'Found ${_foundNotes.length} notes',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                : Text(
                                    'Found ${_foundNotes.length} note',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 5.0,
                          children: [
                            // Title Sort Label and Button
                            TextButton.icon(
                              onPressed: () {
                                _sortByTitle(!_sortTitleAscending);
                              },
                              icon: Icon(
                                _sortTitleAscending
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                              ),
                              label: Text(
                                _sortTitleAscending
                                    ? !isNarrow
                                        ? 'Title A to Z'
                                        : 'Title'
                                    : !isNarrow
                                        ? 'Title Z to A'
                                        : 'Title',
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                            // Date Sort Label and Button
                            TextButton.icon(
                              onPressed: () {
                                _sortByModDate(!_sortModDateAscending);
                              },
                              icon: Icon(
                                _sortModDateAscending
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                              ),
                              label: Text(
                                _sortModDateAscending
                                    ? !isNarrow
                                        ? 'Date First Modified'
                                        : 'Date'
                                    : !isNarrow
                                        ? 'Date Last Modified'
                                        : 'Date',
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                    itemCount: _foundNotes.length,
                    itemBuilder: (context, index) => Card(
                      child: Center(
                        child: Container(
                          decoration: _foundNotes[index].isSelected
                              ? BoxDecoration(
                                  color: theme.colorScheme.onInverseSurface,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                )
                              : const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                          child: ListTile(
                            // Select note button
                            leading: SizedBox(
                              width: NoteIconSize.width,
                              child: Center(
                                child: Ink(
                                  decoration: buttonShapeList,
                                  child: IconButton(
                                    icon: _foundNotes[index].isSelected
                                        ? const Icon(Icons.done)
                                        : const Icon(Icons.edit_document),
                                    onPressed: () {
                                      updateSelected(index);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              _foundNotes[index].content.noteTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Filename: ${_foundNotes[index].noteFileName} \n'
                              'Created on: ${getDateTimeStr(_foundNotes[index].content.createdDateTime)} \n'
                              'Last modified: ${getDateTimeStr(_foundNotes[index].content.modifiedDateTime)}\n'
                              'Shared with: ${getRecipNbrStr(_foundNotes[index].content.authUsers.length)}',
                              maxLines: 4, // Limit to 4 lines
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Define width to avoid consuming full width
                            trailing: SizedBox(
                              height: NoteIconSize.height,
                              width: NoteIconSize.twoIconWidth,
                              child: TrailingButtons(
                                note: _foundNotes[index],
                              ),
                            ),
                            onTap: () {
                              navToChildPage(
                                context: context,
                                childPage: ViewNote(
                                  note: _foundNotes[index],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TrailingButtons extends StatelessWidget {
  const TrailingButtons({
    super.key,
    required FoundOwnNote note,
  }) : _note = note;

  final FoundOwnNote _note;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 15,
      children: [
        // Share button
        SimpleActionButton(
          icon: const Icon(Icons.share),
          childPage: ShareNote(
            note: _note,
            backPage: const ListNotesScreen(),
          ),
        ),
        // Open note icon
        const Icon(
          Icons.arrow_forward,
        ),
      ],
    );
  }
}
