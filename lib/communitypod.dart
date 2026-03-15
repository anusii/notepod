/// CommunityPod - The primary [MaterialApp] widget.
///
// Time-stamp: <Friday 2025-10-24 11:59:49 +1100 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
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
/// Authors: Graham Williams, Anushka Vidanage, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:communitypod/constants/app.dart';
import 'package:communitypod/constants/colours.dart';
import 'package:communitypod/home.dart';
import 'package:communitypod/notes/list_my_notes_screen.dart';

/// The root widget for the [CommunityPod] app.
///
/// The widget essentially orchestrates the building of other
/// widgets. Generically we set up to build a Home widget containing the
/// App. For SolidPod we wrap the Home widget within [SolidLogin] to start with
/// a login screen, though this is optional.

class CommunityPod extends StatelessWidget {
  CommunityPod({super.key});

  final scaffoldController = SolidScaffoldController();

  @override
  Widget build(BuildContext context) {
    return SolidThemeApp(
      title: shortTitle,
      debugShowCheckedModeBanner: false,
      theme: lightThemeData(),
      darkTheme: darkThemeData(),
      home: SolidLogin(
        title: longTitle,
        appDirectory: appDir,
        image: backgroundImg,
        logo: logoImg,
        link: applicationRepo,
        webID: defWebID,
        required: false,
        loginButtonStyle: const LoginButtonStyle(
          background: Colors.lightGreenAccent,
          tooltip: 'You need to connect to your Solid account\n'
              'to access the markdown note files\n'
              'stored in your POD.',
        ),
        child: AppHomePage(
          childPage: ListMyNotesScreen(
            scaffoldController: scaffoldController,
          ),
        ),
      ),
    );
  }
}
