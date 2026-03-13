/// Data models for user's notes
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
import 'package:notepod/models/note.dart';

/// Data model for user's note

class OwnNote {
  final String noteFileName;
  final String noteUrl;
  final String noteOwner;
  NoteContent? content;
  final Map<dynamic, dynamic>? authUserList;

  OwnNote({
    required this.noteFileName,
    required this.noteUrl,
    required this.noteOwner,
    this.content,
    this.authUserList,
  });

  factory OwnNote.fromJson(Map<String, dynamic> json) {
    return OwnNote(
      noteFileName: json[noteFileNamePred],
      noteUrl: json[noteUrlPred],
      noteOwner: json[noteOwnerPred],
      content: json[contentPred],
      authUserList: json[authUserPred],
    );
  }

  Map<String, dynamic> toJson() => {
        noteFileNamePred: noteFileName,
        noteUrlPred: noteUrl,
        noteOwnerPred: noteOwner,
        contentPred: content,
        authUserPred: authUserList,
      };

  /// Copy method for creating a new instance that is an
  /// updated copy of another instance

  OwnNote copyWith({
    String? noteFileName,
    String? noteUrl,
    String? noteOwner,
    NoteContent? content,
    Map<dynamic, dynamic>? authUserList,
  }) {
    return OwnNote(
      noteFileName: noteFileName ?? this.noteFileName,
      noteUrl: noteUrl ?? this.noteUrl,
      noteOwner: noteOwner ?? this.noteOwner,
      content: content ?? this.content,
      authUserList: authUserList ?? this.authUserList,
    );
  }
}
