/// The home page for the app.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:32:47 +1100 Graham Williams>
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
/// Authors: Graham Williams, Anushka Vidanage

library;

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/home.dart';
import 'package:podnotes/login/token_expiry.dart';
import 'package:podnotes/master_key_setup/enc_key_input.dart';
import 'package:podnotes/nav_drawer.dart';
import 'package:podnotes/notes/list_notes_screen.dart';
import 'package:podnotes/notes/view_edit_note_screen.dart';
import 'package:podnotes/shared_notes/list_shared_notes_screen.dart';
import 'package:podnotes/shared_notes/non_readable_note.dart';
import 'package:podnotes/shared_notes/view_edit_shared_note_screen.dart';
//import 'package:simple_markdown_editor/simple_markdown_editor.dart';

class NavigationScreen extends StatefulWidget {
  final String webId;
  final Map authData;
  final String page;
  final String? noteFileName;
  final List? sharedNoteData;

  const NavigationScreen(
      {super.key,
      required this.webId,
      required this.authData,
      required this.page,
      this.noteFileName,
      this.sharedNoteData,});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<NavigationScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic loadingScreen;
    String page = widget.page;
    String webId = widget.webId;
    Map authData = widget.authData;

    /// Check whether token is expired or not.
    /// If expired redirect to the login page
    String accessToken = authData['accessToken'];
    bool hasExpired = JwtDecoder.isExpired(accessToken);
    
    if(hasExpired) {
      loadingScreen = TokenExpiry(authData: authData, webId: webId,);
    } else {
      bool isKeyExist =
          authData['keyExist'] ? authData.containsKey('keyExist') : false;
      if (!isKeyExist) {
        page = 'encKeyInput';
      }

      if (page == 'home') {
        loadingScreen = Home(webId: webId, authData: authData);
      } else if (page == 'encKeyInput') {
        loadingScreen = EncryptionKeyInput(
          validEncKey: ValueNotifier(isKeyExist),
          webId: webId,
          authData: authData,
        );
      } else if (page == 'listNotes') {
        loadingScreen = ListNotesScreen(
          webId: webId,
          authData: authData,
        );
      } else if (page == 'viewNote') {
        loadingScreen = ViewEditNoteScreen(
          noteFileName: widget.noteFileName!,
          webId: webId,
          authData: authData,
          action: 'view',
        );
      } else if (page == 'editNote') {
        loadingScreen = ViewEditNoteScreen(
          noteFileName: widget.noteFileName!,
          webId: webId,
          authData: authData,
          action: 'edit',
        );
      } else if (page == 'sharedNotes') {
        loadingScreen = ListSharedNotesScreen(
          webId: webId,
          authData: authData,
        );
      } else if (page == 'viewSharedNote') {
        loadingScreen = ViewEditSharedNoteScreen(
          sharedNoteData: widget.sharedNoteData!,
          webId: webId,
          authData: authData,
          action: 'view',
        );
      } else if (page == 'editSharedNote') {
        loadingScreen = ViewEditSharedNoteScreen(
          sharedNoteData: widget.sharedNoteData!,
          webId: webId,
          authData: authData,
          action: 'edit',
        );
      } else if (page == 'nonReadNote') {
        loadingScreen = NonReadableNote(
          noteMetaData: widget.sharedNoteData!,
          webId: webId,
          authData: authData,
        );
      }
    }

    if(hasExpired) {
      return Scaffold(
      appBar: AppBar(
        backgroundColor: lightGreen,
        centerTitle: true,
        title: const Text("POD Note Taker"),
      ),
      body: loadingScreen,
    );
    } else {
      return Scaffold(
      appBar: AppBar(
        backgroundColor: lightGreen,
        centerTitle: true,
        title: const Text("POD Note Taker"),
      ),
      drawer: NavDrawer(
        webId: widget.webId,
        authData: widget.authData,
      ),
      body: loadingScreen,
    );
    }
    
    
  }
}
