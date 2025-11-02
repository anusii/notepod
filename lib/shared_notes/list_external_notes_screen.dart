/// List shared notes screen
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

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/models/external_notes_call_result.dart';
import 'package:notepod/shared_notes/list_external_notes.dart';
import 'package:notepod/widgets/err_card.dart';
import 'package:notepod/widgets/loading_screen.dart';
import 'package:notepod/widgets/msg_card.dart';
// import 'package:notepod/widgets/note_list_revoke_dialog.dart';

class ListExternalNotesScreen extends StatefulWidget {
  const ListExternalNotesScreen({
    super.key,
  });

  @override
  State<ListExternalNotesScreen> createState() =>
      _ListExternalNotesScreenState();
}

class _ListExternalNotesScreenState extends State<ListExternalNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Future? _asyncDataFetch;

  @override
  void initState() {
    _asyncDataFetch = getExternalNoteList(
      context: context,
      childPage: const ListExternalNotesScreen(),
    );
    super.initState();
  }

  /// Load external notes if notes found. If any unaccessible note
  /// records found, first navigate to a dialog to revoke access to
  /// these notes.
  ///
  /// Arguments:
  ///   [results] - [ExternalNotesCallResult] class containing [notes]
  /// of files found in user's app data folder, and [badFiles] list of
  /// any unparseable files.
  Widget _loadedExternalNotesScreen(ExternalNotesCallResult results) {
    final notes = results.notes!;
    final unparseableFiles = results.unparseableFiles!;
    final nonExistentFiles = results.nonExistentFiles!;

    if (nonExistentFiles.isNotEmpty) {
      debugPrint('Non existent files: $nonExistentFiles');
      // return NotesRevokeDialog(
      //   badFiles: badFiles,
      //   childPage: ListExternalNotes(notes: notes),
      // );
    }

    if (unparseableFiles.isNotEmpty) {
      debugPrint('Non existent files: $nonExistentFiles');
    }

    // } else if (notes.isEmpty) {
    if (notes.isEmpty) {
      return _noExternalNotes();
    } else {
      return ListExternalNotes(notes: notes);
    }
  }

  Center _noExternalNotes() {
    return Center(
      child: Row(
        children: <Widget>[
          Expanded(
            // MsgCard style works in light and dark themes
            child: buildMsgCard(
              context,
              Icons.info,
              Colors.amber,
              'No shared notes!',
              noSharedNotesMsg,
            ),
          ),
        ],
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
                  // Future failed with error
                  debugPrint('Error: ${snapshot.error.toString()}');
                  return errCard(
                    context,
                    'Error: data loading failed',
                  );
                  // } else if (snapshot.hasData &&
                  //     snapshot.data != null &&
                  //     snapshot.data.length > 0) {
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Notes found
                  // return ListExternalNotes(notes: snapshot.data);
                  return _loadedExternalNotesScreen(
                    snapshot.data as ExternalNotesCallResult,
                  );
                } else if (snapshot.data == null ||
                    snapshot.data.toString() == 'null' ||
                    snapshot.data.length == 0) {
                  // No shared notes found
                  return _noExternalNotes();
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
