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

import 'package:solidui/solidui.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/services/note_service.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/models/notes_call_result.dart';
import 'package:notepod/models/selected_note.dart';
import 'package:notepod/notes/list_notes.dart';
import 'package:notepod/notes/new_note.dart';
import 'package:notepod/widgets/err_card.dart';
import 'package:notepod/widgets/msg_card.dart';
import 'package:notepod/widgets/note_list_del_dialog.dart';
import 'package:notepod/widgets/note_list_revoke_dialog.dart';

/// A [StatefulWidget] that fetches the user's notes in their app data folder
/// retrieving the note data map containing data and properties of each note
/// file name.
///
/// Parameters:
///   [scaffoldController] - Controller for the Solid scaffold.

class ListNotesScreen extends StatefulWidget {
  final SolidScaffoldController scaffoldController;

  const ListNotesScreen({
    super.key,
    required this.scaffoldController,
  });

  @override
  State<ListNotesScreen> createState() => _ListNotesScreenState();
}

class _ListNotesScreenState extends State<ListNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Future function to retrieve user's notes list
  // static Future? _fetchOwnNotes;
  late Future<NotesCallResult> _fetchOwnNotes;

  /// Future function to retrieve externally owned notes list
  // static Future? _fetchExternalNotes;
  late Future<NotesCallResult> _fetchExternalNotes;

  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  @override
  void initState() {
    super.initState();
    _scaffoldController = widget.scaffoldController;

    _scrollController = ScrollController();

    // Set future functions to fetch owner's notes and external notes
    _fetchOwnNotes = NoteService().getOwnNoteList();
    _fetchExternalNotes = getExternalNoteList();
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
  ///   [ownerListResults] - [NotesCallResult] class containing [notes] of
  /// files found in user's app data folder, and [unparseableNotes]
  /// list of any unparseable files.
  ///   [extListResults] - [NotesCallResult] class containing [notes] of
  /// files shared to user, and [unparseableNotes]
  /// list of any unparseable files.

  Widget _loadedNotesScreen(
    NotesCallResult ownerListResults,
    NotesCallResult extListResults,
    SolidScaffoldController scaffoldController,
  ) {
    // Combine the results
    NotesCallResult results =
        ownerListResults.addCallResults(results: extListResults);
    final List<Note> notes = results.notes!;
    final List<SelectedNote> unparseableNotes = results.unparseableNotes!;
    final List<Note> inaccessibleNotes = results.inaccessibleNotes!;

    if (unparseableNotes.isNotEmpty) {
      // Show dialog to optionally delete any unparseable notes if found
      // These are notes that have been incorrectly written and
      // are unparseable.
      return NotesDelDialog(
        unparseableNotes: unparseableNotes,
        childPage: ListNotes(
          notes: notes,
          title: '$combinedNotesTitle ($combinedNotesExplanation)',
          scaffoldController: scaffoldController,
        ),
        scaffoldController: _scaffoldController,
      );
    } else if (inaccessibleNotes.isNotEmpty) {
      // Show dialog to optionally revoke access to any nonexistent notes if found
      // These are notes that were shared to the user and then deleted
      // without revoking access to the user before deleting the note
      // as such these notes are still in the user's permission log
      // without a revoke entry. The dialog provides an option to
      // revoke the user's access to these now inaccessible notes.
      return NotesRevokeDialog(
        inaccessibleNotes: inaccessibleNotes,
        childPage: ListNotes(
          notes: notes,
          title: '$combinedNotesTitle ($combinedNotesExplanation)',
          scaffoldController: _scaffoldController,
        ),
        scaffoldController: _scaffoldController,
      );
    } else if (notes.isEmpty) {
      // If no notes accessible to user, show create new note widget
      return _loadNewNote(scaffoldController);
    } else {
      return ListNotes(
        notes: notes,
        title: '$combinedNotesTitle ($combinedNotesExplanation)',
        scaffoldController: scaffoldController,
      );
    }
  }

  /// Advises user to create their first note if no notes found.
  ///
  /// Arguments: none.
  Widget _loadNewNote(SolidScaffoldController scaffoldController) {
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
            NewNote(
              scaffoldController: scaffoldController,
            ),
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
          // future: _asyncFetchOwnNotes,
          future: Future.wait([
            // Future result of fetching owner's notes list
            _fetchOwnNotes,
            // Future result of fetching externally owned notes list
            _fetchExternalNotes,
          ]),
          builder: (context, snapshot) {
            // if (!snapshot.hasData) {
            //   return Scaffold(body: loadingScreen(normalLoadingScreenHeight));
            // }
            // final PermissionDetails initCurrentPerm =
            //     snapshot.data![0] as PermissionDetails;
            // final List<LogRecord> initPermHistoryList =
            //     snapshot.data![1] as List<LogRecord>;
            // return initCurrentPerm.permissionMap.isEmpty
            //     ? _buildPermPage(context)
            //     : _buildPermPage(context, initCurrentPerm, initPermHistoryList);

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
                  final NotesCallResult ownerNotesListResult =
                      snapshot.data![0];
                  final NotesCallResult extNotesListResult = snapshot.data![1];
                  // Successfully returned NotesCallResult
                  return _loadedNotesScreen(
                    ownerNotesListResult,
                    extNotesListResult,
                    // snapshot.data as NotesCallResult,
                    _scaffoldController,
                  );
                } else if (snapshot.data == null ||
                    snapshot.data.toString() == 'null') {
                  // No notes found
                  return _loadNewNote(_scaffoldController);
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
