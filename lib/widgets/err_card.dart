/// Error card widget
///
// Time-stamp: <Friday 2025-09-30 19:27:10 +1000 Graham Williams>
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:notepod/widgets/msg_card.dart';

// Builds a stylised card for display of error messages,
/// which works in light and dark themes
Center errCard(
  BuildContext context,
  String errBody,
) {
  return Center(
    child: Row(
      children: <Widget>[
        Expanded(
          // MsgCard style works in light and dark themes
          child: buildMsgCard(
            context,
            Icons.error,
            Colors.amber,
            'Error',
            errBody,
          ),
        ),
      ],
    ),
  );
}
