/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Monday 2025-09-15 08:31:39 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:26:39 +1100 Graham Williams>
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
/// Authors: Anushka Vidanage, Graham Williams

library;

/// Colour contants for the app.

import 'package:flutter/material.dart';

/// Shaded colour for meta data in displaying a note.

final metaDataShade = Colors.grey[100];

// Ideally name constants by function.

// const darkGold = Color(0xFFBE830E);
const darkBlue = Color.fromARGB(255, 7, 87, 153);
// const brickRed = Color(0xFFD89E7A);
const lightGreen = Color.fromARGB(255, 120, 219, 137);
const darkGreen = Color.fromARGB(255, 64, 163, 81);
const lightBlue = Color(0xFF61B2CE);
// const exLightBlue = Color(0xFFD8ECF3);
const darkCopper = Color(0xFFBE4E0E);
const titleAsh = Color(0xFF30384D);
const backgroundWhite = Color(0xFFF5F6FC);
const lightGray = Color(0xFF8793B2);
const lighterGray = Color.fromARGB(255, 243, 243, 243);
//const bgOffWhite = Color(0xFFF2F4FC);
//const kTitleTextColor = Color(0xFF30384D);
//const warningRed = Colors.red;

const lightRed = Color.fromARGB(255, 255, 88, 77);
const darkRed = Color.fromARGB(255, 139, 38, 30);

//const confirmGreen = Colors.green;

List<Color> defaultNotepodColors = const [
  darkBlue,
  darkGreen,
  darkCopper,
  titleAsh,
  lightBlue,
];

// Light theme
ThemeData lightThemeData(BuildContext context) {
  return ThemeData(
    useMaterial3: true, // Enable Material 3 design
    brightness: Brightness.light,
    primarySwatch:
        Colors.green, // Colors.blue, // Generates various shades of blue
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green[300], // Colors.blue,
      foregroundColor: Colors.black, // Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    primaryColor: Colors.black,
    // colorScheme: const ColorScheme.light().copyWith(
    //   surfaceTint: Colors.transparent,
    // ),
    // Define other colors as needed, e.g., accentColor, textTheme, etc.
    // Make Scrollbars() visible by default
    // before user starts scrolling in pages
    // where content exceeds container
    // jm 20250916: Known issue with scrollbarTheme not applying
    // in iOS https://github.com/flutter/flutter/issues/143926
    // thumbVisibility: true still required in Scrollbar() instances
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
    ),
  );
}

// Dark theme
ThemeData darkThemeData(BuildContext context) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo, // Different primary color for dark theme
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green[900],
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    primaryColor: Colors.black,
    // colorScheme: const ColorScheme.dark().copyWith(
    //     // surfaceTint: Colors.transparent,
    //     ),
    // Define other colors for dark theme
    // Make Scrollbars() visible by default
    // before user starts scrolling in pages
    // where content exceeds container
    // jm 20250916: Known issue with scrollbarTheme not applying
    // in iOS https://github.com/flutter/flutter/issues/143926
    // thumbVisibility: true still required in Scrollbar() instances
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
    ),
  );
}
