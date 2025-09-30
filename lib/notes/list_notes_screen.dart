/// List notes screen - first fetches notes and then gets recipients for the notes
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

import 'package:solidpod/solidpod.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/notes/list_notes.dart';
import 'package:notepod/notes/new_note.dart';
import 'package:notepod/widgets/loading_screen.dart';
import 'package:notepod/widgets/msg_card.dart';

/// A [StatefulWidget] that fetches the user's notes in their app data folder,
/// retrieving the note data map containing data and properties of each note
/// file name.
/// Following completion, NewNote() is called if no notes are found.
/// Alternatively, if notes exist, ListRecipientsScreen() is called to
/// retrieve the access control list for notes (required to support sharing
/// of notes and display of sharing information).
// Parameters: none
class ListNotesScreen extends StatefulWidget {
  const ListNotesScreen({super.key});

  @override
  State<ListNotesScreen> createState() => _ListNotesScreenState();
}

class _ListNotesScreenState extends State<ListNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Future comprising notesData
  static Future? _asyncDataFetch;

  // /// Scroll controller for single child scroll view
  // final ScrollController _scrollController = ScrollController();
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  @override
  void initState() {
    _asyncDataFetch = getNoteList(context, ListNotesScreen());
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  /// Load Notes if notes found.
  /// Parameters:
  ///   [notesMap] - list of files with data in a user's app data folder.
  Widget _loadedNotesScreen(Map<String, dynamic> notesMap) {
    return ListRecipientsScreen(notesMap: notesMap);
  }

  /// Advise user to create their first note, if no notes found.
  /// Parameters - none.
  Widget _loadNewNote() {
    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            // MsgCard style works in light and dark themes
            buildMsgCard(
              context, Icons.info, Colors.amber, 'No notes yet!',
              'Write your first note',
              // noNotesMsg,
              isSmall: true,
            ),
            NewNote(),
          ],
        ),
      ),
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
          },
        ),
      ),
    );
  }
}

/// A [StatefulWidget] that uses the note filenames in [notesMap]
/// to retrieve the access control list data for each note filename.
/// This adds the recipients and permissions of all recipients for
/// each file record in [notesMap].
/// After completion, run ListNotes() to display the notes.
/// Parameters:
///   [notesMap] is the map comprising a list of notes and data in a
///              user's Pod.
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

  // /// Scroll controller for single child scroll view
  // final ScrollController _scrollController = ScrollController();
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  @override
  void initState() {
    _asyncRecipientsAdd = getAccessLists(
      widget.notesMap,
      context,
      ListRecipientsScreen(
        notesMap: widget.notesMap,
      ),
    );
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  /// Load Notes with recipients data embedded.
  Widget _loadedNotesWRecScreen(Map notesMap) {
    return ListNotes(notesMap: notesMap);
  }

  /// Load error window
  Widget _loadNotesWRecError() {
    return Scrollbar(
      // thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            // MsgCard style works in light and dark themes
            buildMsgCard(
              context, Icons.info, Colors.amber,
              'Error adding recipients to notes!', 'Yikes',
              // noNotesMsg,
              isSmall: true,
            ),
          ],
        ),
      ),
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
                'Finished running _asyncRecipientsAdd to get recipients of each file',
              );
              // Show error if null returned as null indicates error
              return snapshot.data == null || snapshot.data.toString() == 'null'
                  ? returnVal = _loadNotesWRecError()
                  // Else load notes list (which now includes recipients)
                  : returnVal = _loadedNotesWRecScreen(snapshot.data! as Map);
            } else {
              returnVal = loadingScreen(normalLoadingScreenHeight);
            }
            return returnVal;
          },
        ),
      ),
    );
  }
}
