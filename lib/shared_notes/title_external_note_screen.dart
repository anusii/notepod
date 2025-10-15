/// A stateful widget for getting external note content to display title.
///
// Time-stamp: <Tuesday 2025-09-23 05:30:50 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025 Software Innovation Institute, Australian National University
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
/// Authors: Jess Moore
library;

import 'package:flutter/material.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/models/external_note.dart';
import 'package:notepod/shared_notes/list_external_notes_screen.dart';

/// A [stateful] widget for displaying the title of an externally owned
/// note.
///
/// Arguments:
/// - [note] - The externally owned note.

class TitleExternalNoteScreen extends StatefulWidget {
  const TitleExternalNoteScreen({
    super.key,
    required this.note,
  });

  final FoundExternalNote note;

  @override
  State<TitleExternalNoteScreen> createState() =>
      _TitleExternalNoteScreenState();
}

class _TitleExternalNoteScreenState extends State<TitleExternalNoteScreen> {
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
  void didUpdateWidget(covariant TitleExternalNoteScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fetch data when the widget configuration changes (eg new data).
    _note = widget.note;
    _asyncDataFetch = getSharedNoteContent(
      context: context,
      childPage: ListExternalNotesScreen(),
      fullNote: _note,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _asyncDataFetch,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case (ConnectionState.waiting || ConnectionState.active):
            return CircularProgressIndicator(
              value: null,
              strokeWidth: 7.0,
            );
          case ConnectionState.done:
            if (snapshot.hasData && snapshot.data != null) {
              // Data found
              return Text(
                (snapshot.data as FoundExternalNote).content!.noteTitle,
              );
            } else if (snapshot.hasError) {
              debugPrint('Error: ${snapshot.error.toString()}');
              return Text('Error: no data');
            } else {
              return Text('Error: no data');
            }

          case ConnectionState.none:
            debugPrint('Error: No future set in title call.}');
            return Text('Error: Title not loaded, please reload');
        }
      },
    );
  }
}
