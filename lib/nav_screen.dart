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
/// Authors: Graham Williams

import 'package:flutter/material.dart';

import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:podnotes/common/colours.dart';
import 'package:podnotes/home.dart';
import 'package:podnotes/nav_drawer.dart';
//import 'package:simple_markdown_editor/simple_markdown_editor.dart';

class NavigationScreen extends StatefulWidget {
  String webId;
  Map authData;
  String page;

  NavigationScreen(
      {Key? key,
      required this.webId,
      required this.authData,
      required this.page})
      : super(key: key);

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

    if (page == 'home') {
      loadingScreen = Home(webId: webId, authData: authData);
    }
    // else if (page == 'settings') {
    //   loadingScreen = ParticipantProfileScreen(
    //     profData: profileData!,
    //     authData: authData,
    //     webId: webId,
    //   );
    // }
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
