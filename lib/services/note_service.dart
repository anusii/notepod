/// Service class for note file operations.
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Wednesday 2023-11-01 08:26:39 +1100 Graham Williams>
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

import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/models/notes_call_result.dart';
import 'package:notepod/models/selected_note.dart';
import 'package:notepod/services/operations.dart';
import 'package:notepod/services/pod_service.dart';
import 'package:notepod/utils/turtle/note_serializer.dart';

/// Service class for note file operations.

class NoteService with PodOperationsMixin {
  NoteService();

  /// Gets the list of the user's own note objects from their Pod.
  ///
  /// Scans the Pod directory for note files, reads and decrypts each one, then
  /// parses the TTL content into [Note] objects. Files that are empty,
  /// undecrypted, or unparseable are collected in [NotesCallResult.unparseableNotes].
  ///
  /// Returns: [NotesCallResult] with [notes] and [unparseableNotes].

  Future<NotesCallResult> getOwnNoteList() async {
    final noteOwner = await getWebId() ?? '';
    final rawFiles = await PodService().scanAndReadPodFiles(noteFileNamePrefix);

    final List<Note> notes = [];
    final List<SelectedNote> unparseableNotes = [];

    for (final f in rawFiles) {
      // Edge case 1: empty content.
      if (f.ttlContent.isEmpty) {
        debugPrint('Found empty file: ${f.fileName}');
        unparseableNotes.add(
          SelectedNote(
            noteFileName: f.fileName,
            noteUrl: f.url,
            noteOwner: noteOwner,
          ),
        );
        continue;
      }

      // Edge case 2: undecrypted content — solidpod silently returns the raw
      // encrypted TTL (containing 'encData') when the individual key is missing.
      if (f.ttlContent.contains('encData')) {
        debugPrint('Undecrypted content detected in: ${f.fileName}');
        unparseableNotes.add(
          SelectedNote(
            noteFileName: f.fileName,
            noteUrl: f.url,
            noteOwner: noteOwner,
          ),
        );
        continue;
      }

      // Edge cases 3 & 4: null parse result / exception.
      try {
        final record = TurtleSerializer.noteFromTurtle(
          f.ttlContent,
        );
        // final record = BookSerialiser().bookRecordFromTTL(f.ttlContent);
        if (record != null) {
          notes.add(
            Note(
              noteFileName: f.fileName,
              noteUrl: f.url,
              noteOwner: noteOwner,
              content: record,
              permissionList: 'append,read,write,control',
            ),
          );
        } else {
          debugPrint('Found unparseable file: ${f.fileName}');
          unparseableNotes.add(
            SelectedNote(
              noteFileName: f.fileName,
              noteUrl: f.url,
              noteOwner: noteOwner,
            ),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    if (notes.isEmpty) {
      return NotesCallResult(unparseableNotes: unparseableNotes);
    }

    final permissionMaps = await readPermissionFileList(
      fileList: notes.map((n) => n.noteFileName).toList(),
    );
    return NotesCallResult(
      notes: notes.addAuthUserLists(permissionMaps: permissionMaps),
      unparseableNotes: unparseableNotes,
    );
  }
}
