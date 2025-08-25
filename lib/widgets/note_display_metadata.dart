/// DESCRIPTION
///
// Time-stamp: <Friday 2025-07-18 06:44:23 +1000 Graham Williams>
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
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/utils/misc.dart';

/// Display the note metadata.
/// One of fullNoteData, noteContent or noteInfo must be supplied
/// One of showDates, showSharing or showPathInfo must be supplied
/// showDates requires fullNoteData or noteContent
/// showSharing requires fullNoteData or noteInfo
/// showPathInfo requires fullNoteData or noteInfo

class NoteDisplayMetadata extends StatelessWidget {
  final Map fullNoteData;
  final Map noteContent;
  final Map noteInfo;
  final bool showDates;
  final bool showSharing;
  final bool showPathInfo;

  const NoteDisplayMetadata({
    super.key,
    this.fullNoteData = const {},
    this.noteContent = const {},
    this.noteInfo = const {},
    this.showDates = false,
    this.showSharing = false,
    this.showPathInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    Map noteInfo = {};
    Map noteContent = {};
    if (fullNoteData.isNotEmpty) {
      noteInfo = fullNoteData['sharedNoteInfo'];
      noteContent = fullNoteData['sharedNoteContent'];
    } else if (noteInfo.isNotEmpty) {
      noteInfo = noteInfo;
    } else if (noteContent.isNotEmpty) {
      noteContent = noteContent;
    }

    return Container(
      color: metaDataShade,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ShowDates (created and modified)
          if (showDates) dateInfo(noteContent),
          // Show sharing info (owner, provider, access list)
          if (showSharing) accessInfo(noteInfo),
          // Show path info (filename and path)
          if (showPathInfo) pathInfo(noteInfo),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

// Display sharing metadata (owner, provider, access list).

Widget accessInfo(Map noteInfo) {
  return Container(
    color: metaDataShade,
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

// Display path metadata (filename and path).

Widget pathInfo(Map noteInfo) {
  return Container(
    color: metaDataShade,
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: metadataPadding,
                child: Text(
                  'Note file name: ${noteInfo[noteFileName]}',
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
                  'Note path: ${noteInfo[noteUrl]}',
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

// Show date metadata (creation date, modified date)

Widget dateInfo(Map noteContent) {
  return Container(
    color: metaDataShade,
    child: Column(
      children: [
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
      ],
    ),
  );
}
