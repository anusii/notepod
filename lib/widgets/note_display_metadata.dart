/// DESCRIPTION
///
// Time-stamp: <Friday 2025-07-18 05:39:05 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
/// Authors: Jess Moore
library;

import 'package:flutter/material.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/utils/misc.dart';

// Displays note metadata

class NoteDisplayMetadata extends StatelessWidget {
  final Map data;
  final bool shared;

  const NoteDisplayMetadata({
    Key? key,
    required this.data,
    required this.shared,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map noteInfo = {};
    Map noteContent = {};
    if (shared) {
      noteInfo = data['sharedNoteInfo'];
      noteContent = data['sharedNoteContent'];
    } else {
      noteContent = data;
    }

    return Container(
      color: Colors.grey[100],
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    padding: metadataPadding,
                    child: Text(
                      'Created on: ${getDateTimeStr(noteContent[createdDateTimePred])}',
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
                    child: Text(
                      'Last modified on: ${getDateTimeStr(noteContent[modifiedDateTimePred])}',
                      style: metadataTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            // Show sharing metadata if shared external file
            if (shared) accessInfo(noteInfo),
            SizedBox(height: 10),
          ]),
    );
  }
}

// Metadata block containing access info (owner, provider, access list)
Widget accessInfo(noteInfo) {
  return Container(
    color: Colors.grey[100],
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: metadataPadding,
                child: Text(
                  'Owner: ${noteInfo[noteOwner]}',
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
                child: Text(
                  'Shared by: ${noteInfo[permissionGranter]}',
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
                child: Text(
                  'Permissions: ${noteInfo[permissionList]}',
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
