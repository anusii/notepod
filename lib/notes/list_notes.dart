/// Individual's PODs app for diabetes care in Yarrabah.
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

import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/utils/misc.dart';

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
  // true: ascending, false: descending
  bool _sortTitleAscending = true;

  @override
  void initState() {
    // By default _foundNotes is the full list of notes
    _foundNotes = widget.notesMap;
    fileNames = _foundNotes.keys.toList();
    // Initial sort by title
    _sortByTitle(_sortTitleAscending);
    super.initState();
  }

  void _sortByTitle(bool ascending) {
    // Sort the items by name
    setState(() {
      _sortTitleAscending = ascending;
      fileNames
        ..sort((a, b) => _sortTitleAscending
            ? _foundNotes[a][noteTitlePred]
                .toLowerCase()
                .compareTo(_foundNotes[b][noteTitlePred].toLowerCase())
            : _foundNotes[b][noteTitlePred]
                .toLowerCase()
                .compareTo(_foundNotes[a][noteTitlePred].toLowerCase()));

      debugPrint('running _sortByTitle(${_sortTitleAscending.toString()})');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 10, 0),
            child: Text(
              'My Notes (created by me)',
              style: titleStyle,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 10, 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                  _sortTitleAscending ? 'Title A to Z' : 'Title Z to A',
                  style: smallTextStyle,
                ),
                iconAlignment: IconAlignment.end,
              ),
            ]),
          ),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _foundNotes.length,
                itemBuilder: (context, index) => Card(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: ListTile(
                        leading: const CircleAvatar(
                          radius: 26,
                          backgroundImage:
                              AssetImage('assets/images/note-icon.png'),
                        ),
                        //const Icon(Icons.text_snippet_outlined),
                        title:
                            Text(_foundNotes[fileNames[index]][noteTitlePred]),
                        subtitle: Text(
                            'Created on: ${getDateTimeStr(_foundNotes[fileNames[index]][createdDateTimePred])} \nLast modified: ${getDateTimeStr(_foundNotes[fileNames[index]][modifiedDateTimePred])}'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppScreen(
                                title: topBarTitle,
                                childPage: ViewNote(
                                  noteData: _foundNotes[fileNames[index]],
                                ),
                              ),
                            ),
                            (Route<dynamic> route) =>
                                false, // This predicate ensures all previous routes are removed
                          );
                        },
                      ),
                    )),
          ),
        ],
      ),
    );
  }
}
