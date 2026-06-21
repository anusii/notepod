/// Widget for display of date metadata for a note
///
// Time-stamp: <Friday 2025-10-14 14:59:05 +1000 Graham Williams>
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
import 'package:notepod/utils/misc.dart';

/// Show date metadata of a note ie. the creation date time
/// and the modified date time.
///
/// Arguments:
/// - [createdDateTime] - The created date time stamp of the note
/// file.
/// - [modifiedDateTime] - The last modified date time stamp of the
/// note file.

class ShowDateMetadata extends StatelessWidget {
  final String createdDateTime;
  final String modifiedDateTime;

  const ShowDateMetadata({
    super.key,
    required this.createdDateTime,
    required this.modifiedDateTime,
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
                  child: SelectableText(
                    'Created on: ${getDateTimeStr(createdDateTime)}',
                    style: metadataTextStyle,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: metadataPadding,
                  child: SelectableText(
                    'Last modified on: ${getDateTimeStr(modifiedDateTime)}',
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
