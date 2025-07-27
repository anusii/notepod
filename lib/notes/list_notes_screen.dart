/// List notes screen - first fetches notes and then gets recipients for the notes
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

import 'package:solidpod/src/solid/get_access_lists.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/notes/list_notes.dart';
import 'package:notepod/notes/new_note.dart';
import 'package:notepod/widgets/loading_screen.dart';
import 'package:notepod/widgets/msg_card.dart';

/// Process to fetch the user's notes, retrieving the noteData
/// map where each key is the ttl note file with an embedded map
/// comprising different properties of the note including content.
/// The filenames are passed to _loadedNotesScreen() which calls
/// ListRecipientsScreen() to add the recipients data to each note.

class ListNotesScreen extends StatefulWidget {
  const ListNotesScreen({super.key});

  @override
  State<ListNotesScreen> createState() => _ListNotesScreenState();
}

class _ListNotesScreenState extends State<ListNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Future? _asyncDataFetch;

  @override
  void initState() {
    _asyncDataFetch = getNoteList(context, ListNotesScreen());
    super.initState();
  }

  // Load Notes if notes found
  Widget _loadedNotesScreen(Map<String, dynamic> notesMap) {
    return Container(
        color: Colors.white,

        // Run add recipients fetching screen
        child: ListRecipientsScreen(notesMap: notesMap));
  }

  // Advise user to create their first note if no notes found
  Widget _loadNewNote() {
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        buildMsgCard(context, Icons.info, Colors.amber, 'No notes yet!',
            'Write your first note',
            // noNotesMsg,
            isSmall: true),
        Container(
          color: Colors.white,
          child: NewNote(),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: FutureBuilder(
            future: _asyncDataFetch,
            builder: (context, snapshot) {
              Widget returnVal;
              if (snapshot.connectionState == ConnectionState.done) {
                return snapshot.data == null ||
                        snapshot.data.toString() == 'null' ||
                        snapshot.data.length == 0
                    // Show _loadNewNote() to go instead to NewNote() when user has no notes
                    ? returnVal = _loadNewNote()
                    // Else load notes list
                    : returnVal = _loadedNotesScreen(
                        snapshot.data! as Map<String, dynamic>,
                      );
              } else {
                returnVal = loadingScreen(normalLoadingScreenHeight);
              }
              return returnVal;
            }),
      ),
    );
  }
}

/// Process to fetch the recipients data for the list of user's notes,
/// and embed the recipients data with the note data. The ttl filename
/// of each note is used as the key. The filenames are passed to
/// _loadedNotesWRecScreen() which calls ListNotes() to display the
/// list of notes with recipients

class ListRecipientsScreen extends StatefulWidget {
  final Map<String, dynamic> notesMap;
  const ListRecipientsScreen({
    super.key,
    required this.notesMap,
  });

  @override
  State<ListRecipientsScreen> createState() => _ListRecipientsScreenState();
}

class _ListRecipientsScreenState extends State<ListRecipientsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Future comprising notesData with recipients added

  static Future? _asyncRecipientsAdd;

  @override
  void initState() {
    _asyncRecipientsAdd = getAccessLists(
      widget.notesMap,
      context,
      ListRecipientsScreen(
        notesMap: widget.notesMap,
      ),
    );
    super.initState();
  }

  /// Load Notes with recipients data embedded
  Widget _loadedNotesWRecScreen(Map notesMap) {
    return Container(
      color: Colors.white,
      child: ListNotes(notesMap: notesMap),
    );
  }

  /// Load error window
  Widget _loadNotesWRecError() {
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        buildMsgCard(context, Icons.info, Colors.amber,
            'Error adding recipients to notes!', 'Yikes',
            // noNotesMsg,
            isSmall: true),
      ]),
    );
  }

  // Fetch note recipient data and add to notes map
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: FutureBuilder(
            future: _asyncRecipientsAdd,
            builder: (context, snapshot) {
              Widget returnVal;
              if (snapshot.connectionState == ConnectionState.done) {
                debugPrint(
                    'Finished running _asyncRecipientsAdd to get recipients of each file');
                // Show error if null returned as null indicates error
                return snapshot.data == null ||
                        snapshot.data.toString() == 'null'
                    ? returnVal = _loadNotesWRecError()
                    // Else load notes list (which now includes recipients)
                    : returnVal = _loadedNotesWRecScreen(snapshot.data! as Map);
              } else {
                returnVal = loadingScreen(normalLoadingScreenHeight);
              }
              return returnVal;
            }),
      ),
    );
  }
}
