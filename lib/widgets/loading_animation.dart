/// DESCRIPTION
///
// Time-stamp: <Friday 2025-06-27 13:53:06 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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
/// Authors: AUTHORS

library;

import 'package:flutter/material.dart';

import 'package:new_loading_indicator/new_loading_indicator.dart';

import 'package:notepod/constants/colours.dart';

Future<dynamic> showAnimationDialog(
  BuildContext context,
  String alertMsg,
  bool showPathBackground,
) {
  // Delegates to solidui's showAnimationDialog for consistency and reduces duplicate code.
  // Using animationIndex 0 (ballScaleRipple) as a reasonable default.
  return showAnimationDialogSolid(context, 0, alertMsg, showPathBackground, null);
}

// Alias to avoid name clash with the delegating function.
Future<void> showAnimationDialogSolid(
  BuildContext context,
  int animationIndex,
  String alertMsg,
  bool showPathBackground,
  VoidCallback? updateStateCallback,
) => solidui.showAnimationDialog(
      context, animationIndex, alertMsg, showPathBackground, updateStateCallback);

  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(50),
        child: Center(
          child: SizedBox(
            width: 150,
            height: 250,
            child: Column(
              children: [
                // Colours work in light and dark themes
                LoadingIndicator(
                  indicatorType: Indicator.ballScaleRipple,
                  colors: defaultNotepodColors,
                  strokeWidth: 4.0,
                  pathBackgroundColor: showPathBackground
                      ? const Color.fromARGB(59, 0, 0, 0)
                      : null,
                ),
                DefaultTextStyle(
                  style: (const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  )),
                  child: Text(
                    alertMsg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
