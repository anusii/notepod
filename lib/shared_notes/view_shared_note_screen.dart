/// A stateful widget for retrieving content to view an externally owned
/// note.
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
import 'package:notepod/models/external_note.dart';
import 'package:notepod/shared_notes/list_external_notes_screen.dart';
import 'package:notepod/shared_notes/view_shared_note.dart';
import 'package:notepod/widgets/err_card.dart';
import 'package:notepod/widgets/loading_screen.dart';

/// A stateful widget for retrieving content to view an externally owned
/// note.
///
/// Arguments:
/// - [note] - The externally owned note to view.

class ViewSharedNoteScreen extends StatefulWidget {
  const ViewSharedNoteScreen({
    super.key,
    required this.note,
  });

  final FoundExternalNote note;

  @override
  State<ViewSharedNoteScreen> createState() => _ViewSharedNoteScreenState();
}

class _ViewSharedNoteScreenState extends State<ViewSharedNoteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Future? _asyncDataFetch;
  late final FoundExternalNote _note;

  @override
  void initState() {
    _note = widget.note;

    _asyncDataFetch = getSharedNoteContent(
      context: context,
      childPage: ListExternalNotesScreen(),
      fullNote: _note,
    );
    super.initState();
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
                  return ViewSharedNote(
                    note: snapshot.data as FoundExternalNote,
                  );
                } else if (snapshot.data == null ||
                    snapshot.data.toString() == 'null' ||
                    snapshot.data.length == 0) {
                  // No data returned
                  debugPrint('Error: no data found for note');
                  return errCard(
                    context,
                    'Error: no data found for note',
                  );
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
