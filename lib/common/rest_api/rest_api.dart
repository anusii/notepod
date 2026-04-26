/// Functions used to fetch data in future builders.
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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/call_status.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/models/note_content.dart';
import 'package:notepod/models/notes_call_result.dart';
import 'package:notepod/models/selected_note.dart';
import 'package:notepod/services/pod_service.dart';
import 'package:notepod/utils/turtle/note_serializer.dart';

/// Get data object of externally owned notes shared with the user.
///
/// Arguments:
/// - [hasCurrentAccess] - Flag describing whether user has current
/// access (ie. not revoked) to external file. If false, all files
/// which the user has or has previously been granted access will be returned. (Default: true, ie. only returns list of external notes
/// that user has current access to.
///
/// Returns: [NotesCallResult] object comprising:
/// - [notes] - list of [Note] note objects.
/// - [unparseableNotes] - list of [SelectedNote] objects of
/// unparseable notes.
/// - [nonExistentNotes] - list of non-existent [Note] note
/// objects, if external files were deleted by their owner without
/// first revoking access to the user (and other recipients).

Future<NotesCallResult> getExternalNoteList({
  bool hasCurrentAccess = true,
}) async {
  final startTime = DateTime.now();

  // Scan permission log for note files, filtering by prefix and revoke status.
  final List<Note> notes = await PodService().scanExternalFileLog<Note>(
    fileNamePrefix: noteFileNamePrefix,
    parseLogRecord: PodService.extFileDetailsFromLog,
    hasCurrentAccess: hasCurrentAccess,
  );

  // Fetch and deserialize external note file content
  // or count bad files according to error type
  try {
    final List<Note> fullNotes = [];
    final List<Note> nonExistentNotes = [];
    final List<SelectedNote> unparseableNotes = [];
    final NotesCallResult results;

    if (notes.isNotEmpty) {
      // Create a list of future functions for reading external Pods
      List<Future<dynamic>> futuresExtNotesContentResult = [];
      for (final note in notes) {
        futuresExtNotesContentResult.add(
          getExternalNoteContent(
            note: note,
          ),
        );
      }

      List<dynamic> extNotesWithContentResults =
          await Future.wait(futuresExtNotesContentResult);

      // Retrieve notes file data
      for (int i = 0; i < notes.length; i++) {
        if (extNotesWithContentResults[i] ==
            FileCallStatus.fileAccessForbidden) {
          // Files with access forbidden have notes file with default null content
          fullNotes.add(notes[i]);
        } else if (extNotesWithContentResults[i] ==
            FileCallStatus.parsingFail) {
          unparseableNotes.add(
            SelectedNote(
              noteFileName: notes[i].noteFileName,
              noteUrl: notes[i].noteUrl,
              noteOwner: notes[i].noteOwner,
            ),
          );
        } else if (extNotesWithContentResults[i] ==
            FileCallStatus.fileNotExists) {
          nonExistentNotes.add(notes[i]);
        } else if (extNotesWithContentResults[i] != null) {
          // Add notes object content data to notes objects list
          fullNotes.add(extNotesWithContentResults[i]);
        }
      }
    }

    results = NotesCallResult(
      notes: fullNotes,
      nonExistentNotes: nonExistentNotes,
      unparseableNotes: unparseableNotes,
    );

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    debugPrint(
      '[getExternalNotesList] Load time: ${duration.inMilliseconds} ms',
    );

    return results;
  } catch (e) {
    // Error finding files
    debugPrint(e.toString());
    rethrow;
  }
}

/// Get the content of an externally owned note shared with the user.
///
/// Arguments:
/// - [note] - The externally owned note data object including metadata.
///
/// Returns: [FileCallStatus] object comprising one of:
/// - [note] - [Note] note object containing note content.
/// - [FileCallStatus] - where [FileCallStatus] captures read failures
/// including [FileCallStatus.fileNotExists] and
/// [FileCallStatus.parsingFail].

Future<dynamic> getExternalNoteContent({
  required Note note,
}) async {
  try {
    // Check permissions include read
    if (!note.permissionList.contains('read')) {
      return FileCallStatus.fileAccessForbidden;
    }

    // Get decrypted note content from external file
    final noteContentResult = await readExternalPod(
      note.noteUrl,
    );

    // Extract external note ttl data to noteContent
    try {
      // Deserialize note content
      final NoteContent? content;
      content = TurtleSerializer.noteFromTurtle(noteContentResult);

      if (content != null) {
        // Add note content data to external notes object
        note.content = content;
        return note;
      } else {
        // Found external note file with unparseable note content
        return FileCallStatus.parsingFail;
      }
    } catch (e) {
      // Error deserializing note
      debugPrint(e.toString());
      return FileCallStatus.parsingFail;
    }
  } on ResourceNotExistException catch (e) {
    // File does not exist on the POD
    debugPrint('Resource not found: $e');
    return FileCallStatus.fileNotExists;
  } on Object catch (e) {
    // Catches both Exception and Error subclasses (e.g. ArgumentError from
    // pointycastle when the private key block type is unsupported).
    debugPrint('Exception reading external note ${note.noteUrl}: $e');
    return FileCallStatus.parsingFail;
  }
}
