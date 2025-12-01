/// Simple action button widget.
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

import 'package:notepod/constants/colours.dart';
import 'package:notepod/utils/nav_to_child.dart';

/// Simple action button widget with icon only for using in narrow
/// windows or list items.
///
/// Arguments:
/// - [icon] - icon to show on button.
/// - [childPage] - child page to navigate to.
/// - [backgroundColor] - set button background color. (Default: grey [ButtonBackgroundColor.def]).
/// - [foregroundColor] - set button foreground color. (Default [ButtonForegroundColor.white]).

class SimpleActionButton extends StatelessWidget {
  /// Button icon
  final Icon icon;

  /// Childpage
  final Widget childPage;

  /// Button background color
  final Color backgroundColor;

  /// Button foreground color
  final Color foregroundColor;

  const SimpleActionButton({
    super.key,
    required this.icon,
    required this.childPage,
    this.backgroundColor = ButtonBackgroundColor.def,
    // When SimpleActionButton called independently, default foreground color
    // is ButtonForegroundColor.list
    this.foregroundColor = ButtonForegroundColor.list,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Ink(
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: const CircleBorder(),
        ),
        child: IconButton(
          color: foregroundColor,
          icon: icon,
          onPressed: () async {
            // Redirect.
            navToChildPage(context: context, childPage: childPage);
          },
        ),
      ),
    );
  }
}
