/// Full size action button widget.
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

import 'package:communitypod/constants/colours.dart';

/// Elevated button widget with text label for using in note views.
///
/// Arguments:
/// - [label] - text label to show on button.
/// - [icon] - icon to show on button.
/// - [childPage] - child page to navigate to.
/// - [scaffoldController] - Controller for the Solid scaffold.
/// - [backgroundColor] - set button background color. (Default: grey [ButtonBackgroundColor.def]).

class FullSizeActionButton extends StatelessWidget {
  /// Button label
  final String label;

  /// Button icon
  final Icon icon;

  /// Childpage
  final Widget childPage;

  final SolidScaffoldController scaffoldController;

  /// Button background color
  final Color backgroundColor;

  const FullSizeActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.childPage,
    required this.scaffoldController,
    this.backgroundColor = ButtonBackgroundColor.def,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color
      icon: icon,
      onPressed: () async {
        // Redirect.
        scaffoldController.navigateToSubpage(childPage);
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
          ),
      label: Text(
        label,
      ),
    );
  }
}
