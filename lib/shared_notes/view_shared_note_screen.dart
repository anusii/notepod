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
/// Authors: Anushka Vidanage
library;

import 'package:flutter/material.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/shared_notes/edit_shared_note.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';
import 'package:notepod/shared_notes/view_shared_note.dart';
import 'package:notepod/widgets/loading_screen.dart';

class ViewSharedNoteScreen extends StatefulWidget {
  const ViewSharedNoteScreen({
    super.key,
    required this.sharedNoteData,
  });

  final Map sharedNoteData;

  @override
  State<ViewSharedNoteScreen> createState() => _ViewSharedNoteScreenState();
}

class _ViewSharedNoteScreenState extends State<ViewSharedNoteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Future? _asyncDataFetch;

  @override
  void initState() {
    Map sharedNoteData = widget.sharedNoteData;

    _asyncDataFetch = getSharedNoteContent(
      context,
      SharedNotesScreen(),
      sharedNoteData,
    );
    super.initState();
  }

  Widget _loadedScreen(Map sharedNoteContent) {
    return Container(
      color: Colors.white,
      child: ViewSharedNote(
        fullNoteData: {
          'sharedNoteInfo': widget.sharedNoteData,
          'sharedNoteContent': sharedNoteContent
        },
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
                returnVal = _loadedScreen(
                  snapshot.data! as Map,
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
