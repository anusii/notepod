/// A widget to display note metadata in a collapsible panel.
///
// Time-stamp: <Friday 2025-10-14 14:59:05 +1000 Graham Williams>
///
/// Copyright (C) 2025-2026, Software Innovation Institute, ANU
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

import 'package:notepod/widgets/show_access_metadata.dart';
import 'package:notepod/widgets/show_date_metadata.dart';
import 'package:notepod/widgets/show_filename_metadata.dart';
import 'package:notepod/widgets/show_path_metadata.dart';

/// Display the metadata of an externally owned note.
/// showDates requires created and modified date time.
/// showSharing requires note owner, premission granter and
/// permission list.
/// showPathInfo requires note file name and note url.
///
/// Arguments:
/// - [createdDateTime] - note created date time.
/// - [modifiedDateTime] - note last modified data time.
/// - [noteOwner] - webId of note owner.
/// - [permissionGranter] - webId of entity that shared the note
/// to the user.
/// - [permissionList] - list of permissions granted to the user.
/// - [noteFileName] - note file name.
/// - [noteUrl] - url of note.
/// - [showDates] - flag describing whether to show data metadata of
/// note.
/// - [showFileName] - flag describing whether to show filename of
/// note.
/// - [showSharing] - flag describing whether to show sharing
/// metadata of note.
/// - [showPathInfo] - flag describing whether to show url path of
/// note.

class DisplayNoteMetadata extends StatelessWidget {
  final String createdDateTime;
  final String modifiedDateTime;
  final String noteOwner;
  final String? permissionGranter;
  final String? permissionList;
  final String noteFileName;
  final String noteUrl;

  final bool isExternal;
  final bool showDates;
  final bool showFileName;
  final bool showSharing;
  final bool showPathInfo;

  const DisplayNoteMetadata({
    super.key,
    this.createdDateTime = '',
    this.modifiedDateTime = '',
    this.noteOwner = '',
    this.permissionGranter,
    this.permissionList,
    this.noteFileName = '',
    this.noteUrl = '',
    this.isExternal = false,
    this.showDates = false,
    this.showFileName = false,
    this.showSharing = false,
    this.showPathInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Build the list of metadata children — same content as before.
    final children = <Widget>[
      if (showFileName && noteFileName.isNotEmpty)
        ShowFilenameMetadata(filename: noteFileName),
      if (showDates &&
          createdDateTime.isNotEmpty &&
          modifiedDateTime.isNotEmpty)
        ShowDateMetadata(
          createdDateTime: createdDateTime,
          modifiedDateTime: modifiedDateTime,
        ),
      if (showSharing)
        ShowAccessMetadata(
          noteOwner: noteOwner,
          permissionGranter: permissionGranter!,
          permissionList: permissionList!,
        ),
      if (showPathInfo && noteUrl.isNotEmpty)
        ShowPathMetadata(fileUrl: noteUrl),
      const SizedBox(height: 8),
    ];

    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      color: cs.onInverseSurface,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 15),
        leading: Icon(
          Icons.info_outline,
          size: 18,
          color: cs.onSurfaceVariant,
        ),
        title: Text(
          'Note details',
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurfaceVariant,
          ),
        ),
        children: children,
      ),
    );
  }
}
