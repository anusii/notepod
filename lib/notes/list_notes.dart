/// List user's own notes.
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://www.gnu.org/licenses/gpl-3.0.en.html
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
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Anushka Vidanage, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidpod/src/solid/constants/common.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/home.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/share_note.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/utils/misc.dart';
import 'package:notepod/widgets/note_share_button.dart';

/// A [StatefulWidget] to list notes owned by the user.
/// Parameters:
///   [notesMap] - is the file list map with data of all notes
///                in the user's app data folder (required to
///                display sharing information and support
///                sharing with suggestion list of recipient WebIds).
class ListNotes extends StatefulWidget {
  final Map notesMap;

  const ListNotes({
    super.key,
    required this.notesMap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ListNotesState createState() => _ListNotesState();
}

class _ListNotesState extends State<ListNotes> {
  Map _foundNotes = {};
  List fileNames = [];
  // Sort order
  // true: ascending (A-Z), false: descending (Z-A)
  // Initial sort will sort alphabetically
  bool _sortTitleAscending = true;
  // true: ascending (oldest modified note), false: descending (last modified note)
  // First button press will change to sort by last modified first
  bool _sortModDateAscending = true;

  /// Scroll controller for single child scroll view
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // By default _foundNotes is the full list of notes
    _foundNotes = widget.notesMap;
    fileNames = _foundNotes.keys.toList();
    // Initial sort by title alphabetically
    _sortByTitle(_sortTitleAscending);
    super.initState();
  }

  // Sort alphanumerically on note title field
  void _sortByTitle(bool ascending) {
    setState(() {
      _sortTitleAscending = ascending;
      fileNames.sort(
        (a, b) => _sortTitleAscending
            ? _foundNotes[a][noteTitlePred]
                .toLowerCase()
                .compareTo(_foundNotes[b][noteTitlePred].toLowerCase())
            : _foundNotes[b][noteTitlePred]
                .toLowerCase()
                .compareTo(_foundNotes[a][noteTitlePred].toLowerCase()),
      );
    });
  }

  // Sort numerically on note modified date field
  void _sortByModDate(bool ascending) {
    setState(() {
      _sortModDateAscending = ascending;
      fileNames.sort(
        (a, b) => _sortModDateAscending
            ? _foundNotes[a][modifiedDateTimePred]
                .compareTo(_foundNotes[b][modifiedDateTimePred])
            : _foundNotes[b][modifiedDateTimePred]
                .compareTo(_foundNotes[a][modifiedDateTimePred]),
      );
    });
  }

  // Search notes
  void _searchNotes(String enteredKeyword) {
    Map results = {};
    if (enteredKeyword.isEmpty) {
      // Display all notes if no search string
      results = widget.notesMap;
    } else {
      // Display notes with title or contents containing search string
      results = Map.fromEntries(
        widget.notesMap.entries.where(
          (note) =>
              (note.value as Map)[noteTitlePred]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              (note.value as Map)[noteContentPred]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()),
        ),
      );
    }

    // Refresh the UI
    setState(() {
      _foundNotes = results;
      fileNames = _foundNotes.keys.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$myNotesTitle (created by me)',
                  style: titleStyle,
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) => _searchNotes(value),
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    hintText: 'Enter string to match title or contents',
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
                    // Search summary statement
                    _foundNotes.length > 1 || _foundNotes.isEmpty
                        ? Text('Found ${_foundNotes.length} notes')
                        : Text('Found ${_foundNotes.length} note'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                            color: Colors.black,
                          ),
                          label: Text(
                            _sortTitleAscending
                                ? 'Title A to Z'
                                : 'Title Z to A',
                            style: smallTextStyle,
                          ),
                          iconAlignment: IconAlignment.end,
                        ),
                        SizedBox(
                          width: 5.0,
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
                            color: Colors.black,
                          ),
                          label: Text(
                            _sortModDateAscending
                                ? 'Date First Modified'
                                : 'Date Last Modified',
                            style: smallTextStyle,
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: _foundNotes.length,
                itemExtent: ownListItemHeight,
                itemBuilder: (context, index) => Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 26,
                      backgroundImage:
                          AssetImage('assets/images/note-icon.png'),
                    ),
                    //const Icon(Icons.text_snippet_outlined),
                    title: Text(_foundNotes[fileNames[index]][noteTitlePred]),
                    subtitle: Text(
                      'Created on: ${getDateTimeStr(_foundNotes[fileNames[index]][createdDateTimePred])} \nLast modified: ${getDateTimeStr(_foundNotes[fileNames[index]][modifiedDateTimePred])}\nShared with: ${getRecipNbrStr(_foundNotes[fileNames[index]][authUserPred].length)}',
                    ),
                    // trailing: TrailingIcons(),
                    // Define width to avoid consuming full width
                    trailing: SizedBox(
                      height: 60,
                      width: 120,
                      child: TrailingButtons(
                        foundNotes: _foundNotes,
                        fileNames: fileNames,
                        index: index,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppHomePage(
                            title: topBarTitle,
                            childPage: ViewNote(
                              noteData: _foundNotes[fileNames[index]],
                              notesMap: widget.notesMap,
                            ),
                          ),
                        ),
                        (Route<dynamic> route) =>
                            false, // This predicate ensures all previous routes are removed
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrailingButtons extends StatelessWidget {
  const TrailingButtons({
    super.key,
    required Map foundNotes,
    required this.fileNames,
    required this.index,
  }) : _foundNotes = foundNotes;

  final Map _foundNotes;
  final List fileNames;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Share button
        NoteShareButton(
          childPage: ShareNote(
            noteData: _foundNotes[fileNames[index]],
            noteFilePath: // Get note file path
                '$noteFileNamePrefix${_foundNotes[fileNames[index]][createdDateTimePred]}.ttl',
            notesMap: _foundNotes,
            backPage: ListNotesScreen(),
          ),
          simple: true,
        ),
        const SizedBox(
          width: 15,
        ),
        // Open note icon
        const Icon(Icons.arrow_forward),
      ],
    );
  }
}
