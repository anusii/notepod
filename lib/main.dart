/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-16 14:49:51 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute, ANU.
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
import 'package:window_manager/window_manager.dart';

import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/utils/is_desktop.dart';
import 'package:notepod/notes/list_notes_screen.dart';

/// Main entry point for the NotePod application.

void main() async {
  // This is the main entry point for the app. The [async] is required because
  // we asynchronously [await] the window manager below. Often, `main()` will
  // include only [runApp].

  // Globally remove [debugPrint] messages.

  // debugPrint = (String? message, {int? wrapWidth}) {
  //   null;
  // };

  // Ensure Flutter bindings are initialized for async operations

  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktop) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      // Set various desktop window options here.

      // Setting [alwaysOnTop] here will ensure the app starts on top of other
      // apps on the desktop so that it is visible (otherwise, with GNOME on
      // Ubuntu the app is often lost below other windows on startup).
      // We later turn it off as we don't want to force it always on top.

      alwaysOnTop: true,

      // The [title] is used for the window manager's window title.

      title: 'NotePod - A note taking app with private PODs',
    );

    // Once the window manager is ready we reconfigure it a little.

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setAlwaysOnTop(false);
    });
  }

  // The runApp() function takes the given Widget and makes it the root of the
  // widget tree.

  runApp(const NotePod());
}

// The main widget could be in a separate file, but handy having it in main and
// the file is not too large. The widget essentially orchestrates the building
// of other widgets. Generically we set up to build a `Home()` widget containing
// the App. For SolidPod we wrap the `Home()` widget within the `SolidLogin()`
// widget so we start with a login screen, though this is optional.

/// The root widget of the NotePod application.

class NotePod extends StatelessWidget {
  const NotePod({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Taker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
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
        child: AppScreen(
          title: topBarTitle,
          childPage: ListNotesScreen(),
        ),
      ),
    );
  }
}
