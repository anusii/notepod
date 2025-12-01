/// Widget for display of filename metadata for a note
///
// Time-stamp: <Friday 2025-10-30 16:36:05 +1100 Graham Williams>
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

import 'package:notepod/constants/app.dart';

/// Display filename metadata of a note ie. the filename.
///
/// Arguments:
/// - [filename] - Filename of the note.

class ShowFilenameMetadata extends StatelessWidget {
  final String filename;

  const ShowFilenameMetadata({
    super.key,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onInverseSurface,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: metadataPadding,
                  child: Text(
                    'Note file name: $filename',
                    style: metadataTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
