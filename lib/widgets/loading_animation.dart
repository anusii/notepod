/// Loading animation dialog for NotePod.
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

import 'package:solidui/solidui.dart' as solidui;

import 'package:notepod/constants/colours.dart';

/// Display a NotePod-styled loading animation dialog.

Future<void> showAnimationDialog(
  BuildContext context,
  String alertMsg,
  bool showPathBackground,
) {
  return solidui.showAnimationDialog(
    context,
    0,
    alertMsg,
    showPathBackground,
    null,
    colors: defaultNotepodColors,
    strokeWidth: 4.0,
    width: 150,
    height: 250,
    showCancelButton: false,
    indicatorType: solidui.Indicator.ballScaleRipple,
  );
}
