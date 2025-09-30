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
import 'package:notepod/shared_notes/list_shared_notes.dart';
import 'package:notepod/widgets/loading_screen.dart';
import 'package:notepod/widgets/err_card.dart';
import 'package:notepod/widgets/msg_card.dart';

class SharedNotesScreen extends StatefulWidget {
  const SharedNotesScreen({
    super.key,
  });

  @override
  State<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends State<SharedNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Future? _asyncDataFetch;

  @override
  void initState() {
    _asyncDataFetch = getSharedNotes(context, SharedNotesScreen());
    super.initState();
  }

  Center _noSharedNotes() {
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

  Widget _loadedScreen(Map sharedNotesMap) {
    return ListSharedNotes(
      sharedNotesMap: sharedNotesMap,
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
                } else if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data.length > 0) {
                  // Notes found
                  return _loadedScreen(
                    snapshot.data! as Map,
                  );
                } else if (snapshot.data == null ||
                    snapshot.data.toString() == 'null' ||
                    snapshot.data.length == 0) {
                  // No shared notes found
                  return _noSharedNotes();
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
