/// List notes screen - fetches user's notes
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

// import 'package:solidpod/solidpod.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/models/notes_call_result.dart';
import 'package:notepod/notes/list_notes.dart';
import 'package:notepod/notes/new_note.dart';
import 'package:notepod/widgets/err_card.dart';
import 'package:notepod/widgets/note_list_del_dialog.dart';
import 'package:notepod/widgets/loading_screen.dart';
import 'package:notepod/widgets/msg_card.dart';

/// A [StatefulWidget] that fetches the user's notes in their app data folder
/// retrieving the note data map containing data and properties of each note
/// file name.
///
/// Parameters: none
class ListNotesScreen extends StatefulWidget {
  const ListNotesScreen({super.key});

  @override
  State<ListNotesScreen> createState() => _ListNotesScreenState();
}

class _ListNotesScreenState extends State<ListNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Future comprising notesData
  static Future? _asyncDataFetch;

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

  /// Load user's notes if notes found. If any unparseable notes
  /// found, first navigate to a dialog to delete unparseable
  /// notes.
  ///
  /// Arguments:
  ///   [results] - [NotesCallResult] class containing [notesMap] of files found in user's app data folder, and [badFiles] list of any unparseable files
  Widget _loadedNotesScreen(NotesCallResult results) {
    final notesMap = results.notesMap!;
    final badFiles = results.badFiles!;

    if (badFiles.isNotEmpty) {
      return NotesDelDialog(
        badFiles: badFiles,
        childPage: ListNotes(notesMap: notesMap),
      );
    } else if (notesMap.isEmpty) {
      return _loadNewNote();
    } else {
      return ListNotes(notesMap: notesMap);
    }
  }

  /// Advises user to create their first note if no notes found.
  ///
  /// Arguments: none.
  Widget _loadNewNote() {
    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            // MsgCard style works in light and dark themes
            // No notes message
            buildMsgCard(
              context,
              Icons.info,
              Colors.amber,
              NoteListMsg.noNotes,
              NoteListMsg.writeFirstNote,
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
            switch (snapshot.connectionState) {
              case (ConnectionState.waiting || ConnectionState.active):
                return loadingScreen(normalLoadingScreenHeight);
              case ConnectionState.done:
                if (snapshot.hasError) {
                  // future failed with error
                  debugPrint('Error: ${snapshot.error.toString()}');
                  return errCard(
                    context,
                    'Error: data loading failed',
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Successfully returned NotesCallResult
                  return _loadedNotesScreen(
                    snapshot.data as NotesCallResult,
                  );
                } else if (snapshot.data == null ||
                    snapshot.data.toString() == 'null') {
                  // No notes found
                  return _loadNewNote();
                } else {
                  // Unknown error
                  return errCard(
                    context,
                    'Unknown error',
                  );
                }

              // Connection none error
              case ConnectionState.none:
                debugPrint('Error: Builder has ConnectionState.none');
                return errCard(
                  context,
                  'Connection error',
                );
            }
          },
        ),
      ),
    );
  }
}
