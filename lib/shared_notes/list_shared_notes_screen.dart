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

import 'package:podnotes/constants/app.dart';
import 'package:podnotes/common/rest_api/rest_api.dart';
import 'package:podnotes/shared_notes/list_shared_notes.dart';
import 'package:podnotes/widgets/loading_screen.dart';
import 'package:podnotes/widgets/msg_card.dart';

class ListSharedNotesScreen extends StatefulWidget {
  const ListSharedNotesScreen(
      {super.key,
      required this.authData,
      required this.webId,});

  final Map authData;
  final String webId;

  @override
  State<ListSharedNotesScreen> createState() => _ListSharedNotesScreenState();
}

class _ListSharedNotesScreenState extends State<ListSharedNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Future? _asyncDataFetch;

  @override
  void initState() {
    Map authData = widget.authData;
    String webId = widget.webId;

    _asyncDataFetch = getSharedNotesList(
      authData,
      webId,
    );
    super.initState();
  }

  Widget _loadedScreen(List sharedNotesList, String webId, Map authData) {
    Widget nextScreen;
    nextScreen = ListSharedNotes(
        sharedNotesList: sharedNotesList,
        webId: webId,
        authData: authData,
      );
    return Container(
      color: Colors.white,
      child: nextScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    Map authData = widget.authData;
    String webId = widget.webId;

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: FutureBuilder(
            future: _asyncDataFetch,
            builder: (context, snapshot) {
              Widget returnVal;
              if (snapshot.connectionState == ConnectionState.done) {
                return snapshot.data == null ||
                      snapshot.data.toString() == "null" || snapshot.data.length == 0
                  ? Center(
                      child: Row(
                        children: <Widget>[
                          Expanded(
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
                    )
                  : returnVal = _loadedScreen(
                    snapshot.data! as List,
                    webId,
                    authData,
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
