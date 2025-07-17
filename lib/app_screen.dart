// App screen.
///
// Time-stamp: <Thursday 2025-07-17 12:16:55 +1000 Graham Williams>
///
/// Copyright (C) 2024, Software Innovation Institute, ANU.
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

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';
import 'package:version_widget/version_widget.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/nav_drawer.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/new_note.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';

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
          const SizedBox(width: 50),
          VersionWidget(
            version: _appVersion,
            changelogUrl:
                // Currently (VersionWidget version 1.0.3) for the chrome/web
                // deployment the first URL results in CORS blocking while the
                // second works. However the second redners raw text when tapped
                // while the first renders the Markdown. (20250717 gjw)
                'https://github.com/anusii/notepod/blob/dev/CHANGELOG.md',
            // 'https://raw.githubusercontent.com/anusii/notepod/dev/CHANGELOG.md',
            showDate: true,
            fontSize: 12.0,
          ),
          const SizedBox(width: 20),
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
                          title: topBarTitle,
                          childPage: NewNote(),
                        )),
                (Route<dynamic> route) =>
                    false, // This predicate ensures all previous routes are removed
              );
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Go to $myNotesTitle',
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
                          title: topBarTitle,
                          childPage: ListNotesScreen(),
                        )),
                (Route<dynamic> route) =>
                    false, // This predicate ensures all previous routes are removed
              );
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Go to $sharedNotesTitle',
            icon: const Icon(
              Icons.file_open_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => AppScreen(
                          title: topBarTitle,
                          childPage: SharedNotesScreen(),
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
