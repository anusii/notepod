// App screen.
//
// Copyright (C) 2024, Software Innovation Institute, ANU.
//
// Licensed under the GNU General Public License, Version 3 (the "License").
//
// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
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
//
// Authors: Anushka Vidanage

import 'package:flutter/material.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/home.dart';
import 'package:notepod/notes/list_notes_screen.dart';

import 'package:solidpod/solidpod.dart';

import 'package:notepod/nav_drawer.dart';

class AppScreen extends StatefulWidget {
  /// Initialise widget variables.
  const AppScreen({super.key, required this.childPage, this.title = ''});

  final Widget childPage;
  final String title;

  @override
  AppScreenState createState() => AppScreenState();
}

class AppScreenState extends State<AppScreen>
    with SingleTickerProviderStateMixin {
  String? _webId;

  Future<({String name, String? webId})> _getInfo() async =>
      (name: await AppInfo.name, webId: await getWebId());

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightGreen,
        centerTitle: true,
        title: Text(widget.title),
        actions: <Widget>[
          const SizedBox(width: 50),
          IconButton(
            tooltip: 'Create a new note',
            icon: const Icon(
              Icons.add_circle,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => AppScreen(
                          childPage: Home(),
                        )),
                (Route<dynamic> route) =>
                    false, // This predicate ensures all previous routes are removed
              );
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'My Notes',
            icon: const Icon(
              // TODO 20231217 gjw view_list icon is not rendering on web. In
              // fact, any other icon I choose except the ones originally used
              // do not render. Must be an extra step required.
              Icons.view_list,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => AppScreen(
                          childPage: ListNotesScreen(),
                        )),
                (Route<dynamic> route) =>
                    false, // This predicate ensures all previous routes are removed
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: NavDrawer(
        webId: _webId ?? '',
      ),
      body: widget.childPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Home Screen'),
    //     // leading: IconButton(
    //     //   icon: const Icon(Icons.arrow_back),
    //     //   onPressed: () {
    //     //     Navigator.pop(context);
    //     //   },
    //     // ),
    //   ),
    //   drawer: const NavDrawer(),
    //   body: const Center(
    //     child: Text('RioPod Test page'),
    //   ),
    // );

    return FutureBuilder<({String name, String? webId})>(
      future: _getInfo(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _webId = snapshot.data?.webId;
          return _build(context);
        } else {
          return const Scaffold(body: CircularProgressIndicator());
        }
      },
    );
  }
}
