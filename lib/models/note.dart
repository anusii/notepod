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

import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/turtle_structures.dart';

/// Base data model for the nested note within a note object

class Note {
  final String noteTitle;
  final String createdDateTime;
  final String modifiedDateTime;
  final String noteContent;
  final List<String> authUsers;

  const Note({
    required this.noteTitle,
    required this.createdDateTime,
    required this.modifiedDateTime,
    required this.noteContent,
    this.authUsers = const [],
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      noteTitle: json[noteTitlePred] as String,
      createdDateTime: json[createdDateTimePred] as String,
      modifiedDateTime: json[modifiedDateTimePred] as String,
      noteContent: json[noteContentPred] as String,
      authUsers: (json[authUserPred] as Map).keys.toList().cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        noteTitlePred: noteTitle,
        createdDateTimePred: createdDateTime,
        modifiedDateTimePred: modifiedDateTime,
        noteContentPred: noteContent,
        authUserPred: authUsers,
      };

  /// Copy method for creating a new instance that is an
  /// updated copy of another instance

  Note copyWith({
    String? noteTitle,
    String? createdDateTime,
    String? modifiedDateTime,
    String? noteContent,
    List<String>? authUsers,
  }) {
    return Note(
      noteTitle: noteTitle ?? this.noteTitle,
      createdDateTime: createdDateTime ?? this.createdDateTime,
      modifiedDateTime: modifiedDateTime ?? this.modifiedDateTime,
      noteContent: noteContent ?? this.noteContent,
      authUsers: authUsers ?? this.authUsers,
    );
  }
}
