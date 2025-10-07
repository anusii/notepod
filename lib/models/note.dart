/// Data models for notes
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Thursday 2025-10-02 17:53:12 +1100 Graham Williams>
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

import 'package:notepod/constants/turtle_structures.dart';

/// Note content data model

class Note {
  final String noteTitle;
  final String createdDateTime;
  final String modifiedDateTime;
  final String noteContent;

  const Note({
    required this.noteTitle,
    required this.createdDateTime,
    required this.modifiedDateTime,
    required this.noteContent,
  });

  Note.fromJson(Map<String, dynamic> json)
      : noteTitle = json[noteTitlePred] as String,
        createdDateTime = json[createdDateTimePred] as String,
        modifiedDateTime = json[modifiedDateTimePred] as String,
        noteContent = json[noteContentPred] as String;

  Map<String, dynamic> toJson() => {
        noteTitlePred: noteTitle,
        createdDateTimePred: createdDateTime,
        modifiedDateTimePred: modifiedDateTime,
        noteContentPred: noteContent,
      };
}

/// External note details data model.

class ExternalNote {
  final String sharedTime;
  final String noteUrl;
  final String noteFileName;
  final String noteOwner;
  final String permissionGranter;
  final String permissionRecepient;
  final String permissionType;
  final String permissionList;

  const ExternalNote({
    required this.sharedTime,
    required this.noteUrl,
    required this.noteFileName,
    required this.noteOwner,
    required this.permissionGranter,
    required this.permissionRecepient,
    required this.permissionType,
    required this.permissionList,
  });

  Map<String, dynamic> toJson() => {
        sharedTimePred: sharedTime,
        noteUrlPred: noteUrl,
        noteFileNamePred: noteFileName,
        noteOwnerPred: noteOwner,
        permissionGranterPred: permissionGranter,
        permissionRecepientPred: permissionRecepient,
        permissionTypePred: permissionType,
        permissionListPred: permissionList,
      };
}
