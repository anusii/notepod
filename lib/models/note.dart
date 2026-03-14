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
import 'package:notepod/models/note_content.dart';
import 'package:notepod/models/own_note.dart';

/// Data model for any note

class Note extends OwnNote {
  final String? sharedTime;
  final String? permissionGranter;
  final String? permissionRecepient;
  final String? permissionType;
  final String? permissionList;
  bool isSelected;

  Note({
    super.content,
    super.authUserList,
    required super.noteUrl,
    required super.noteFileName,
    required super.noteOwner,
    this.sharedTime,
    this.permissionGranter,
    this.permissionRecepient,
    this.permissionType,
    this.permissionList,
    this.isSelected = false,
  });

  /// Method to create Note object from json data map

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      noteUrl: json[noteUrlPred] as String,
      noteFileName: json[noteFileNamePred] as String,
      noteOwner: json[noteOwnerPred] as String,
      sharedTime: json[sharedTimePred] as String,
      permissionGranter: json[permissionGranterPred] as String,
      permissionRecepient: json[permissionRecepientPred] as String,
      permissionType: json[permissionTypePred] as String,
      permissionList: json[permissionListPred] as String,
      isSelected: json[isSelectedPred] as bool,
      content: json[contentPred] as NoteContent,
      authUserList: json[authUserPred] as Map<dynamic, dynamic>,
    );
  }

  /// Method to export Note object to json data map

  @override
  Map<String, dynamic> toJson() => {
        noteUrlPred: noteUrl,
        noteFileNamePred: noteFileName,
        noteOwnerPred: noteOwner,
        sharedTimePred: sharedTime,
        permissionGranterPred: permissionGranter,
        permissionRecepientPred: permissionRecepient,
        permissionTypePred: permissionType,
        permissionListPred: permissionList,
        isSelectedPred: isSelected,
        contentPred: content,
        authUserPred: authUserList,
      };

  /// Copy method for creating a new instance that is an
  /// updated copy of another instance

  @override
  Note copyWith({
    NoteContent? content,
    Map<dynamic, dynamic>? authUserList,
    String? noteUrl,
    String? noteFileName,
    String? noteOwner,
    String? sharedTime,
    String? permissionGranter,
    String? permissionRecepient,
    String? permissionType,
    String? permissionList,
    bool? isSelected,
  }) {
    return Note(
      content: content ?? this.content,
      authUserList: authUserList ?? this.authUserList,
      noteUrl: noteUrl ?? this.noteUrl,
      noteFileName: noteFileName ?? this.noteFileName,
      noteOwner: noteOwner ?? this.noteOwner,
      sharedTime: sharedTime ?? this.sharedTime,
      permissionGranter: permissionGranter ?? this.permissionGranter,
      permissionRecepient: permissionRecepient ?? this.permissionRecepient,
      permissionType: permissionType ?? this.permissionType,
      permissionList: permissionList ?? this.permissionList,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Class for operations on list of notes

extension ListNoteExtension on List<Note> {
  /// Method to add authorised user list map to each file in
  /// list of notes
  ///
  /// Arguments:
  /// - [permissionMaps] - map of permission maps, with the
  /// filename as key and the permission map obtained by
  /// readPermissions() as value.

  List<Note> addAuthUserLists({required Map permissionMaps}) {
    List<Note> updatedNotes = [];

    for (var note in this) {
      final Note updatedNote = note.copyWith(
        authUserList: permissionMaps[note.noteFileName][authUserPred],
      );
      updatedNotes.add(updatedNote);
    }
    return updatedNotes;
  }
}
