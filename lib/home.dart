/// NotePod - The application's home page.
///
// Time-stamp: <Friday 2026-04-24 05:26:11 +1000 Graham Williams>
///
/// Copyright (C) 2024-2026, Software Innovation Institute, ANU.
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

import 'package:notepod/constants/app.dart';
import 'package:notepod/notes/import_export_screen.dart';
import 'package:notepod/notes/list_my_notes_screen.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/new_note.dart';

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
    return SolidScaffold(
      controller: scaffoldController,
      appBar: SolidAppBarConfig(
        title: topBarTitle,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        defaultOverflowActionIds: const {
          'all_notes',
          'my_notes',
          SolidAppBarActionIds.themeToggle,
          SolidAppBarActionIds.logout,
          SolidAppBarActionIds.about,
        },
        versionConfig: const SolidVersionConfig(
          changelogUrl: appChangeLog,
          showDate: true,
          userTextStyle: TextStyle(color: Colors.white),
        ),
        actions: [
          // New Note
          SolidAppBarAction(
            id: 'new_note',
            icon: Icons.add_circle,
            tooltip: newNoteToolTip,
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
            id: 'all_notes',
            icon: Icons.view_list,
            tooltip: combinedNotesToolTip,
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
            id: 'my_notes',
            icon: Icons.person_3,
            tooltip: myNotesToolTip,
            onPressed: () {
              scaffoldController.navigateToSubpage(
                ListMyNotesScreen(
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
          title: combinedNotesTitle,
          icon: Icons.view_list,
          child: ListNotesScreen(scaffoldController: scaffoldController),
          tooltip: combinedNotesToolTip,
        ),
        // My Notes
        SolidMenuItem(
          title: myNotesTitle,
          // More gender neutral icon
          icon: Icons.person_3,
          child: ListMyNotesScreen(scaffoldController: scaffoldController),
          tooltip: myNotesToolTip,
        ),
        // New Note
        SolidMenuItem(
          title: newNoteTitle,
          icon: Icons.add_circle,
          child: NewNote(
            scaffoldController: scaffoldController,
          ),
          tooltip: newNoteToolTip,
        ),
        // Import / Export
        const SolidMenuItem(
          title: importExportTitle,
          icon: Icons.import_export,
          child: ImportExportScreen(),
          tooltip: importExportToolTip,
        ),
        // Invite Others
        SolidMenuItem(
          title: inviteOthersTitle,
          icon: Icons.share,
          tooltip: inviteOthersToolTip,
          onTap: (menuContext) => InviteOthersDialog.show(
            menuContext,
            config: inviteOthersConfig,
          ),
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
      showNotifications: true,
      aboutConfig: const SolidAboutConfig(
        applicationName: longTitle,
        applicationIcon: Icon(Icons.apps, size: 64),
        applicationLegalese: appOwner,
        text: aboutText,
      ),
      inviteConfig: inviteOthersConfig,
      enableProfile: true,
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
