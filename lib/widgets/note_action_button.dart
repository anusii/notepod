/// Action button widget for display on note views or note list items.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Wednesday 2025-10-07 21:17:12 +1100 Graham Williams>
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:notepod/constants/colours.dart';
import 'package:notepod/widgets/full_size_action_button.dart';
import 'package:notepod/widgets/simple_action_button.dart';

///  Note action button widget for display on note views
/// or note list items. A simpler version
/// of the button is displayed with icon only if [showSimple] or
/// [isNarrow] is true.
///
/// Arguments:
/// - [label] - text label to show on button.
/// - [icon] - icon to show on button.
/// - [childPage] - The child widget to navigate to.
/// - [scaffoldController] - Controller for the Solid scaffold.
/// - [backgroundColor] - set button background color. (Default: grey [ButtonBackgroundColor.def]).
/// - [foregroundColor] - set button foreground color. (Default [ButtonForegroundColor.white]).
/// - [showSimple] - Boolean describing whether to show
/// simple version of button without text label.
/// - [isNarrow] - Boolean describing whether displaying
/// in a narrow window.

class NoteActionButton extends StatelessWidget {
  /// Button label
  final String label;

  /// Button icon
  final Icon icon;

  /// Childpage
  final Widget childPage;

  /// Solid scaffold controller
  final SolidScaffoldController scaffoldController;

  /// Button background color
  final Color backgroundColor;

  /// Button foreground color
  final Color foregroundColor;

  /// Show simple button without label
  final bool showSimple;

  /// Boolean describing whether window is narrow
  final bool isNarrow;

  const NoteActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.childPage,
    required this.scaffoldController,
    this.backgroundColor = ButtonBackgroundColor.def,
    this.foregroundColor = ButtonForegroundColor.view,
    this.showSimple = false,
    this.isNarrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return (showSimple || isNarrow)
        ? SimpleActionButton(
            icon: icon,
            childPage: childPage,
            scaffoldController: scaffoldController,
            backgroundColor: backgroundColor,
            // When SimpleActionButton called from NoteActionButton, default foreground color
            // is ButtonForegroundColor.view
            foregroundColor: foregroundColor,
          )
        : FullSizeActionButton(
            label: label,
            icon: icon,
            childPage: childPage,
            scaffoldController: scaffoldController,
            backgroundColor: backgroundColor,
          );
  }
}
