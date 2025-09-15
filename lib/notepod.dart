/// NotePod - The primary [MaterialApp] widget.
///
// Time-stamp: <Monday 2025-09-15 09:30:12 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
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
/// Authors: Graham Williams, Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/home.dart';
import 'package:notepod/notes/list_notes_screen.dart';

/// The root widget for the [NotePod] app.
///
/// The widget essentially orchestrates the building of other
/// widgets. Generically we set up to build a Home widget containing the
/// App. For SolidPod we wrap the Home widget within [SolidLogin] to start with
/// a login screen, though this is optional.

class NotePod extends StatelessWidget {
  const NotePod({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Taker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        // Make Scrollbars() visible by default
        // before user starts scrolling
        // JM 2025/09/15: setting thumbVisibility in each instance
        // as global setting in theme is not being applied.
        // scrollbarTheme: ScrollbarThemeData(
        //   thumbVisibility: WidgetStateProperty.all(true),
        // ),
      ),
      home: SolidLogin(
        title: 'NOTEPOD - A Note Taker',
        appDirectory: 'notepod',
        image: AssetImage('assets/images/notepod-background.jpg'),
        logo: AssetImage('assets/images/notepod.png'),
        link: 'https://github.com/anusii/notepod',
        webID: 'https://pods.solidcommunity.au',
        required: false,
        loginButtonStyle: LoginButtonStyle(
          background: Colors.lightGreenAccent,
          tooltip: 'You need to connect to your Solid account\n'
              'to access the markdown note files\n'
              'stored in your POD.',
        ),
        child: AppHomePage(title: topBarTitle, childPage: ListNotesScreen()),
      ),
    );
  }
}
