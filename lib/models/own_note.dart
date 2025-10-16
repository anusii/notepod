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

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/note.dart';

final String contentPred = 'content';

/// Data model for user's note

class OwnNote {
  final String noteFileName;
  final Note content;

  const OwnNote({
    required this.noteFileName,
    required this.content,
  });

  factory OwnNote.fromJson(Map<String, dynamic> json) {
    return OwnNote(
      noteFileName: json[noteFileNamePred],
      content: json[contentPred],
    );
  }

  Map<String, dynamic> toJson() => {
        noteFileNamePred: noteFileName,
        contentPred: content,
      };

  /// Copy method for creating a new instance that is an
  /// updated copy of another instance

  OwnNote copyWith({
    String? noteFileName,
    Note? content,
  }) {
    return OwnNote(
      noteFileName: noteFileName ?? this.noteFileName,
      content: content ?? this.content,
    );
  }
}

/// Extension of own notes class for found notes,
/// including the selection status of the note.

class FoundOwnNote extends OwnNote {
  bool isSelected;

  FoundOwnNote({
    required super.noteFileName,
    required super.content,
    this.isSelected = false,
  });

  /// Copy method for creating a new instance that is an
  /// updated copy of another instance

  @override
  FoundOwnNote copyWith({
    String? noteFileName,
    Note? content,
    bool? isSelected,
  }) {
    return FoundOwnNote(
      noteFileName: noteFileName ?? this.noteFileName,
      content: content ?? this.content,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Class to operate on list of notes

extension ListOwnNoteExtension on List<OwnNote> {
  /// Convert a List of note maps to a map of note
  /// maps using the note filename as the key for each note
  /// map

  Map<String, Map<String, dynamic>> toMap() {
    Map<String, Map<String, dynamic>> mapOfNoteMaps = {};

    for (var note in this) {
      String key = note.noteFileName;
      Map<String, dynamic> value = note.content.toJson();

      // Add note to map with filename as key
      mapOfNoteMaps[key] = value;
    }
    return mapOfNoteMaps;
  }

  /// Assign list of own notes to list of found own notes
  /// usign default values.

  List<FoundOwnNote> toListFoundOwnNote() {
    List<FoundOwnNote> listFoundNotes = map((item) {
      return FoundOwnNote(
        noteFileName: item.noteFileName,
        content: item.content,
      );
    }).toList();

    return listFoundNotes;
  }
}

/// Convert map of maps to list of user's notes
///
/// Arguments:
/// - [mapOfNoteMaps] - map of user's notes

List<OwnNote> mapOfMapsToListOwnNote(
  Map<String, Map<String, dynamic>> mapOfNoteMaps,
) {
  final List<OwnNote> listOfNoteMaps;
  listOfNoteMaps = mapOfNoteMaps.entries.map((entry) {
    return OwnNote(
      noteFileName: entry.key,
      content: Note.fromJson(entry.value),
    );
  }).toList();

  return listOfNoteMaps;
}
