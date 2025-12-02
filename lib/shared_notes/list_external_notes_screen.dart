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

import 'package:solidui/solidui.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/models/external_notes_call_result.dart';
import 'package:notepod/shared_notes/list_external_notes.dart';
import 'package:notepod/widgets/err_card.dart';
import 'package:notepod/widgets/msg_card.dart';
import 'package:notepod/widgets/note_list_del_dialog.dart';
import 'package:notepod/widgets/note_list_revoke_dialog.dart';

/// A [stateful] widget to fetch data for the page showing list externally
/// owned notes shared to the user.
///
/// Arguments:
/// - [scaffoldController] - Controller for the Solid scaffold.
class ListExternalNotesScreen extends StatefulWidget {
  final SolidScaffoldController scaffoldController;

  const ListExternalNotesScreen({
    super.key,
    required this.scaffoldController,
  });

  @override
  State<ListExternalNotesScreen> createState() =>
      _ListExternalNotesScreenState();
}

class _ListExternalNotesScreenState extends State<ListExternalNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Future? _asyncDataFetch;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  @override
  void initState() {
    super.initState();
    _scaffoldController = widget.scaffoldController;
    _asyncDataFetch = getExternalNoteList(
      context: context,
      childPage: ListExternalNotesScreen(
        scaffoldController: _scaffoldController,
      ),
    );
  }

  /// Load external notes if notes found. If any records of
  /// non-existent notes were found, it will first navigate to
  /// a dialog to revoke access to these notes.
  ///
  /// Arguments:
  ///   [results] - [ExternalNotesCallResult] class containing notes
  /// of files shared to the user, and unparseableNotes list of
  /// any unparseable files, and non-existentNotes list of any notes
  /// that were externally deleted before access was revoked to the user.

  Widget _loadedExternalNotesScreen(ExternalNotesCallResult results) {
    final notes = results.notes!;
    final unparseableNotes = results.unparseableNotes!;
    final nonExistentNotes = results.nonExistentNotes!;

    if (unparseableNotes.isNotEmpty) {
      return NotesDelDialog(
        unparseableNotes: unparseableNotes,
        childPage: ListExternalNotes(
          notes: notes,
          scaffoldController: _scaffoldController,
        ),
        scaffoldController: _scaffoldController,
        isExternal: true,
      );
    } else if (nonExistentNotes.isNotEmpty) {
      return NotesRevokeDialog(
        nonExistentNotes: nonExistentNotes,
        childPage: ListExternalNotes(
          notes: notes,
          scaffoldController: _scaffoldController,
        ),
        scaffoldController: _scaffoldController,
      );
    } else if (notes.isEmpty) {
      return _noExternalNotes();
    } else {
      return ListExternalNotes(
        notes: notes,
        scaffoldController: _scaffoldController,
      );
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
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Notes found
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
