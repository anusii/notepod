/// NotePod - Define the main entry point for the app.
///
// Time-stamp: <Tuesday 2025-10-21 08:43:32 +1100 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute, ANU.
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
/// Authors: Graham Williams, Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';

import 'package:notepod/notepod.dart';
import 'package:notepod/utils/is_desktop.dart';

/// Main entry point for the [NotePod] application.

void main() async {
  // We require [async] because we asynchronously [await] the window manager
  // below. Often, `main()` will include just the call [runApp].

  // Optionally we can globally remove [debugPrint] messages.
  //
  // debugPrint = (String? message, {int? wrapWidth}) {
  //   null;
  // };

  // Ensure Flutter bindings are initialized for async operations, in particular
  // to set the Linux desktop window [title].

  WidgetsFlutterBinding.ensureInitialized();
  if (isDesktop) {
    // 20251009 jm: Required to initialize the
    // window_manager plugin. Failure to include
    // causes a build failure on macos
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      // Set various desktop window options here, specifically the title.

      // Setting [alwaysOnTop] here will ensure the app starts on top of other
      // apps on the desktop so that it is visible (otherwise, with GNOME on
      // Ubuntu the app is often lost below other windows on startup).
      // We later turn it off as we don't want to force it always on top.
      //
      // 20250815 gjw Staying [alwaysOnTop] on startup seems okay now?

      // alwaysOnTop: true,

      title: 'NotePod - Private and Shareable Notes',
    );

    // Once the window manager is ready we reconfigure it a little.

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
//      await windowManager.show();
//      await windowManager.focus();
//      await windowManager.setAlwaysOnTop(false);
    });
  }

  // The runApp() function takes the given Widget and makes it the root of the
  // widget tree.

  runApp(NotePod());
}
