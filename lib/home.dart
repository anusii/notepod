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

import 'package:solidui/solidui.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/nav_drawer.dart';
import 'package:notepod/app_bar.dart';

import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/new_note.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';

class AppHomePage extends StatefulWidget {
  /// Initialise widget variables.
  const AppHomePage({super.key, required this.childPage});

  final Widget childPage;

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

  // Toggle login status
  void _toggleLogin() {
    setState(() {
      _webId = _webId == null ? 'user@example.com' : null;
    });
  }

  Future<({String name, String? webId})> _getInfo() async =>
      (name: await AppInfo.name, webId: await getWebId());

  Widget _build(BuildContext context) {
    debugPrint('Webid: $_webId');
    debugPrint('Appversion: $_appVersion');
    debugPrint('AppInfo: $AppInfo');

    return SolidScaffold(
      appBar: navAppBar(context),
      menu: [
        // My Notes
        SolidMenuItem(
          title: myNotesTitle,
          icon: Icons.view_list,
          child: ListNotesScreen(),
          tooltip: 'Navigate to $myNotesTitle',
        ),
        // New Note
        SolidMenuItem(
          title: newNoteTitle,
          icon: Icons.note_add_outlined,
          child: NewNote(),
          tooltip: 'Navigate to $newNoteTitle',
        ),
        // Shared Notes
        SolidMenuItem(
          title: sharedNotesTitle,
          icon: Icons.groups,
          child: SharedNotesScreen(),
          tooltip: 'Navigate to $sharedNotesTitle',
        ),
      ],
      statusBar: SolidStatusBarConfig(
        serverInfo: SolidServerInfo(
          serverUri: _webId!,
        ),
        securityKeyStatus: SolidSecurityKeyStatus(
          tooltip: 'Manage security keys',
        ),
        loginStatus: SolidLoginStatus(
          webId: _webId,
          onTap: _toggleLogin,
          loggedInText: 'Logged In',
          loggedOutText: 'Not Logged In',
          loggedInTooltip: 'Click to log out',
          loggedOutTooltip: 'Click to log in',
        ),
        showOnNarrowScreens: true,
      ),
      themeToggle: const SolidThemeToggleConfig(
        enabled: true,
      ),
      aboutConfig: SolidAboutConfig(
        applicationName: topBarTitle,
        applicationIcon: Icon(Icons.apps, size: 64),
        applicationLegalese: appOwner,
        text: aboutText,
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
