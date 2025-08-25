/// NotePod - The application's home page.
///
// Time-stamp: <Friday 2025-08-15 09:14:37 +1000 Graham Williams>
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
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
/// Authors: Anushka Vidanage, Jess Moore
library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/nav_drawer.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/new_note.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';

class AppHomePage extends StatefulWidget {
  /// Initialise widget variables.
  const AppHomePage({super.key, required this.childPage, this.title = ''});

  final Widget childPage;
  final String title;

  @override
  AppHomePageState createState() => AppHomePageState();
}

class AppHomePageState extends State<AppHomePage>
    with SingleTickerProviderStateMixin {
  String? _webId;

  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  /// Loads the app name and version from package_info_plus.

  Future<void> _loadAppInfo() async {
    final appInfo = await getAppNameVersion();
    if (mounted) {
      setState(() {
        _appVersion = appInfo.version;
      });
    }
  }

  Future<({String name, String? webId})> _getInfo() async =>
      (name: await AppInfo.name, webId: await getWebId());

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightGreen,
        centerTitle: true,
        title: Text(widget.title),
        actions: <Widget>[
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
                  builder: (context) => AppHomePage(
                    title: topBarTitle,
                    childPage: NewNote(),
                  ),
                ),
                (Route<dynamic> route) =>
                    false, // This predicate ensures all previous routes are removed
              );
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Go to $myNotesTitle',
            icon: const Icon(
              Icons.view_list,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => AppHomePage(
                    title: topBarTitle,
                    childPage: ListNotesScreen(),
                  ),
                ),
                (Route<dynamic> route) =>
                    false, // This predicate ensures all previous routes are removed
              );
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Go to $sharedNotesTitle',
            icon: const Icon(
              // Also tried (20250718 gjw)
              // Icons.people,
              // Icons.share,
              // Icons.group,
              // Icons.supervisor_account,
              // Icons.share_rounded,
              Icons.groups,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => AppHomePage(
                    title: topBarTitle,
                    childPage: SharedNotesScreen(),
                  ),
                ),
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
        appVersion: _appVersion,
      ),
      body: widget.childPage,
    );
  }

  @override
  Widget build(BuildContext context) {
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
