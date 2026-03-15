/// CommunityPod - The application's home page.
///
// Time-stamp: <Friday 2025-08-15 09:14:37 +1000 Graham Williams>
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
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

import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:communitypod/constants/app.dart';
import 'package:communitypod/notes/list_external_notes_screen.dart';
import 'package:communitypod/notes/list_my_notes_screen.dart';
import 'package:communitypod/notes/list_notes_screen.dart';
import 'package:communitypod/notes/new_note.dart';

class AppHomePage extends StatefulWidget {
  /// Initialise widget variables.
  const AppHomePage({super.key, required this.childPage});

  final Widget childPage;

  @override
  AppHomePageState createState() => AppHomePageState();
}

class AppHomePageState extends State<AppHomePage> {
  String? _webId;

  // String _appVersion = '';

  late final SolidScaffoldController
      _scaffoldController; //  = SolidScaffoldController();

  @override
  void initState() {
    super.initState();
    _scaffoldController = SolidScaffoldController();
  }

  @override
  void dispose() {
    _scaffoldController.dispose(); // Dispose the scaffoldController
    super.dispose();
  }

  Future<({String name, String? webId})> _getInfo() async =>
      (name: await AppInfo.name, webId: await getWebId());

  Widget _build(
    BuildContext context,
    SolidScaffoldController scaffoldController,
  ) {
    // Reduce calls to of(context).
    final theme = Theme.of(context);
    return SolidScaffold(
      controller: scaffoldController,
      appBar: SolidAppBarConfig(
        title: topBarTitle,
        backgroundColor: theme.appBarTheme.backgroundColor, // lightGreen,
        versionConfig: SolidVersionConfig(
          changelogUrl: appChangeLog,
          showDate: true,
          userTextStyle: TextStyle(color: theme.colorScheme.onSurface),
          // tooltip: 'Custom version tooltip',
        ),
        actions: [
          // New Note
          SolidAppBarAction(
            icon: Icons.add_circle,
            tooltip: 'Navigate to $newNewsPostTitle',
            onPressed: () {
              scaffoldController.navigateToSubpage(
                NewNote(
                  scaffoldController: scaffoldController,
                ),
              );
            },
          ),
          // All Accessible Notes
          SolidAppBarAction(
            icon: Icons.view_list,
            tooltip: 'Go to $combinedNewsTitle',
            onPressed: () {
              scaffoldController.navigateToSubpage(
                ListNotesScreen(
                  scaffoldController: scaffoldController,
                ),
              );
            },
          ),
          // My Notes (Owner's Notes)
          SolidAppBarAction(
            // More gender neutral icon
            icon: Icons.person_3,
            tooltip: 'Go to $myNewsTitle',
            onPressed: () {
              scaffoldController.navigateToSubpage(
                ListMyNotesScreen(
                  scaffoldController: scaffoldController,
                ),
              );
            },
          ),
          // External Notes (Shared Notes)
          SolidAppBarAction(
            // More gender neutral icon
            icon: Icons.groups_3,
            tooltip: 'Go to $sharedNewsTitle',
            onPressed: () {
              scaffoldController.navigateToSubpage(
                ListExternalNotesScreen(
                  scaffoldController: scaffoldController,
                ),
              );
            },
          ),
        ],
      ),
      menu: [
        // All Accessible Notes
        SolidMenuItem(
          title: combinedNewsTitle,
          icon: Icons.view_list,
          child: ListNotesScreen(scaffoldController: scaffoldController),
          tooltip: 'Navigate to $combinedNewsTitle',
        ),
        // My Notes
        SolidMenuItem(
          title: myNewsTitle,
          // More gender neutral icon
          icon: Icons.person_3,
          child: ListMyNotesScreen(scaffoldController: scaffoldController),
          tooltip: 'Navigate to $myNewsTitle',
        ),
        // Shared Notes
        SolidMenuItem(
          title: sharedNewsTitle,
          // More gender neutral icon
          icon: Icons.groups_3,
          child: ListExternalNotesScreen(
            scaffoldController: scaffoldController,
          ),
          tooltip: 'Navigate to $sharedNewsTitle',
        ),
        // New Note
        SolidMenuItem(
          title: newNewsPostTitle,
          icon: Icons.add_circle,
          child: NewNote(
            scaffoldController: scaffoldController,
          ),
          tooltip: 'Navigate to $newNewsPostTitle',
        ),
      ],
      statusBar: SolidStatusBarConfig(
        serverInfo: SolidServerInfo(
          serverUri: _webId ?? defWebID,
        ),
        securityKeyStatus: const SolidSecurityKeyStatus(
          tooltip: 'Manage security keys',
        ),
        loginStatus: SolidLoginStatus(
          webId: _webId,
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
      aboutConfig: const SolidAboutConfig(
        applicationName: longTitle,
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
          return _build(context, _scaffoldController);
        } else {
          return const Scaffold(body: CircularProgressIndicator());
        }
      },
    );
  }
}
