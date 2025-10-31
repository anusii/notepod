/// Data models for external notes
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Thursday 2025-10-16 10:24:11 +1100 Graham Williams>
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
import 'package:notepod/models/note.dart';

/// Data model for externally owned note shared with the user
class ExternalNote {
  NoteContent? content;
  final String sharedTime;
  final String noteUrl;
  final String noteFileName;
  final String noteOwner;
  final String permissionGranter;
  final String permissionRecepient;
  final String permissionType;
  final String permissionList;

  ExternalNote({
    this.content,
    required this.sharedTime,
    required this.noteUrl,
    required this.noteFileName,
    required this.noteOwner,
    required this.permissionGranter,
    required this.permissionRecepient,
    required this.permissionType,
    required this.permissionList,
  });

  factory ExternalNote.fromJson(Map<String, dynamic> json) {
    return ExternalNote(
      content: json['content'],
      sharedTime: json[sharedTimePred],
      noteUrl: json[noteUrlPred],
      noteFileName: json[noteFileNamePred],
      noteOwner: json[noteOwnerPred],
      permissionGranter: json[permissionGranterPred],
      permissionRecepient: json[permissionRecepientPred],
      permissionType: json[permissionTypePred],
      permissionList: json[permissionListPred],
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        sharedTimePred: sharedTime,
        noteUrlPred: noteUrl,
        noteFileNamePred: noteFileName,
        noteOwnerPred: noteOwner,
        permissionGranterPred: permissionGranter,
        permissionRecepientPred: permissionRecepient,
        permissionTypePred: permissionType,
        permissionListPred: permissionList,
      };

  /// Copy method for creating a new instance that is an
  /// updated copy of another instance

  ExternalNote copyWith({
    NoteContent? content,
    String? sharedTime,
    String? noteUrl,
    String? noteFileName,
    String? noteOwner,
    String? permissionGranter,
    String? permissionRecepient,
    String? permissionType,
    String? permissionList,
  }) {
    return ExternalNote(
      content: content ?? this.content,
      sharedTime: sharedTime ?? this.sharedTime,
      noteUrl: noteUrl ?? this.noteUrl,
      noteFileName: noteFileName ?? this.noteFileName,
      noteOwner: noteOwner ?? this.noteOwner,
      permissionGranter: permissionGranter ?? this.permissionGranter,
      permissionRecepient: permissionRecepient ?? this.permissionRecepient,
      permissionType: permissionType ?? this.permissionType,
      permissionList: permissionList ?? this.permissionList,
    );
  }
}

/// Class to operate on list of notes

extension ListExternalNoteExtension on List<ExternalNote> {
  /// Assign list of external notes to list of found external notes
  /// usign default values.
  List<FoundExternalNote> toListFoundExternalNote() {
    List<FoundExternalNote> listFoundNotes = map((item) {
      return FoundExternalNote(
        content: item.content,
        sharedTime: item.sharedTime,
        noteUrl: item.noteUrl,
        noteFileName: item.noteFileName,
        noteOwner: item.noteOwner,
        permissionGranter: item.permissionGranter,
        permissionRecepient: item.permissionRecepient,
        permissionType: item.permissionType,
        permissionList: item.permissionList,
      );
    }).toList();

    return listFoundNotes;
  }
}

/// Extension of own notes class for found notes,
/// including the selection status of the note.

class FoundExternalNote extends ExternalNote {
  bool isSelected;

  FoundExternalNote({
    super.content,
    required super.sharedTime,
    required super.noteUrl,
    required super.noteFileName,
    required super.noteOwner,
    required super.permissionGranter,
    required super.permissionRecepient,
    required super.permissionType,
    required super.permissionList,
    this.isSelected = false,
  });

  /// Copy method for creating a new instance that is an
  /// updated copy of another instance

  @override
  FoundExternalNote copyWith({
    NoteContent? content,
    String? sharedTime,
    String? noteUrl,
    String? noteFileName,
    String? noteOwner,
    String? permissionGranter,
    String? permissionRecepient,
    String? permissionType,
    String? permissionList,
    bool? isSelected,
  }) {
    return FoundExternalNote(
      content: content ?? this.content,
      sharedTime: sharedTime ?? this.sharedTime,
      noteUrl: noteUrl ?? this.noteUrl,
      noteFileName: noteFileName ?? this.noteFileName,
      noteOwner: noteOwner ?? this.noteOwner,
      permissionGranter: permissionGranter ?? this.permissionGranter,
      permissionRecepient: permissionRecepient ?? this.permissionRecepient,
      permissionType: permissionType ?? this.permissionType,
      permissionList: permissionList ?? this.permissionList,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
