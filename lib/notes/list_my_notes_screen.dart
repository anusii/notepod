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

import 'package:solidpod/solidpod.dart' show isUserLoggedIn;
import 'package:solidui/solidui.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/models/notes_call_result.dart';
import 'package:notepod/models/selected_note.dart';
import 'package:notepod/notes/list_notes.dart';
import 'package:notepod/notes/new_note.dart';
import 'package:notepod/services/note_service.dart';
import 'package:notepod/widgets/err_card.dart';
import 'package:notepod/widgets/msg_card.dart';
import 'package:notepod/widgets/not_logged_in_card.dart';
import 'package:notepod/widgets/note_list_del_dialog.dart';

/// A [StatefulWidget] that fetches the user's notes in their app data folder
/// retrieving the note data map containing data and properties of each note
/// file name.
///
/// Parameters:
///   [scaffoldController] - Controller for the Solid scaffold.

class ListMyNotesScreen extends StatefulWidget {
  final SolidScaffoldController scaffoldController;

  const ListMyNotesScreen({
    super.key,
    required this.scaffoldController,
  });

  @override
  State<ListMyNotesScreen> createState() => _ListMyNotesScreenState();
}

class _ListMyNotesScreenState extends State<ListMyNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Future function to retrieve user's notes list
  Future<NotesCallResult>? _asyncDataFetch;

  /// Tracks the user's login status. `null` while the asynchronous
  /// check is in flight (used to show the loading screen), then
  /// updated by [_checkLoginAndFetch]
  bool? _isLoggedIn;

  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  @override
  void initState() {
    super.initState();
    _scaffoldController = widget.scaffoldController;
    _scrollController = ScrollController();
    _checkLoginAndFetch();
  }

  /// Confirms the user is logged in before triggering the POD fetch.
  ///
  /// When the user is not logged in we skip the fetch entirely and let
  /// [build] render the [NotLoggedInCard] placeholder. Touching the POD
  /// APIs without an authenticated session would otherwise produce a
  /// cascade of rendering exceptions on this screen.

  Future<void> _checkLoginAndFetch() async {
    final loggedIn = await isUserLoggedIn();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = loggedIn;
      _asyncDataFetch = loggedIn ? NoteService().getOwnNoteList() : null;
    });
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
  ///   [results] - [NotesCallResult] class containing [notes] of
  /// files found in user's app data folder, and [unparseableNotes]
  /// list of any unparseable files.

  Widget _loadedNotesScreen(
    NotesCallResult results,
    SolidScaffoldController scaffoldController,
  ) {
    final List<Note> notes = results.notes!;
    final List<SelectedNote> unparseableNotes = results.unparseableNotes!;

    if (unparseableNotes.isNotEmpty) {
      return NotesDelDialog(
        unparseableNotes: unparseableNotes,
        childPage: ListNotes(
          notes: notes,
          title: '$myNotesTitle ($myNotesExplanation)',
          scaffoldController: scaffoldController,
        ),
        scaffoldController: _scaffoldController,
      );
    } else if (notes.isEmpty) {
      return _loadNewNote(scaffoldController);
    } else {
      return ListNotes(
        notes: notes,
        title: '$myNotesTitle ($myNotesExplanation)',
        scaffoldController: scaffoldController,
      );
    }
  }

  /// Advises user to create their first note if no notes found.
  ///
  /// Arguments: none.
  Widget _loadNewNote(SolidScaffoldController scaffoldController) {
    // The outer SingleChildScrollView used to wrap NewNote here, but NewNote
    // contains a Column with an Expanded child (the markdown editor), which
    // cannot be laid out under unbounded vertical constraints. NewNote already
    // handles its own internal scrolling, so use a plain Column with Expanded
    // and let the editor fill the remaining height.

    return Column(
      children: <Widget>[
        // No-notes message (fixed height at top).
        buildMsgCard(
          context,
          Icons.info,
          Colors.amber,
          NoteListMsg.noNotes,
          NoteListMsg.writeFirstNote,
          isSmall: true,
        ),
        // Editor fills the remaining space and provides its own scrolling.
        Expanded(
          child: NewNote(
            scaffoldController: scaffoldController,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show the loading screen until the asynchronous login check has
    // returned. Once we know the user is logged out, render the
    // friendly `Not logged in` placeholder rather than attempting to
    // fetch notes from a POD we cannot read.

    if (_isLoggedIn == null) {
      return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(child: loadingScreen(normalLoadingScreenHeight)),
      );
    }
    if (_isLoggedIn == false) {
      return Scaffold(
        key: _scaffoldKey,
        body: const SafeArea(child: NotLoggedInCard()),
      );
    }

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
