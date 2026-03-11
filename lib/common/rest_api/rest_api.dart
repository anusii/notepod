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

import 'package:notepod/common/rest_api/file_helper.dart';
import 'package:notepod/models/call_status.dart';
import 'package:notepod/models/external_note.dart';
import 'package:notepod/models/external_notes_call_result.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/models/own_note.dart';
import 'package:notepod/models/own_notes_call_result.dart';
import 'package:notepod/models/selected_note.dart';
import 'package:notepod/utils/turtle/note_serializer.dart';

/// Get the list of user's note objects.
///
/// Example:
/// - `_asyncDataFetch = getOwnNoteList()`
/// - used to define async function in future call to get user's notes.
///
/// Returns: [OwnNotesCallResult] object comprising:
/// - [notes] - list of [OwnNote] note objects.
/// - [unparseableNotes] - list of [SelectedNote] objects of
/// unparseable notes.

Future<OwnNotesCallResult> getOwnNoteList() async {
  try {
    final startTime = DateTime.now();

    final List<String> fileList;
    final List<OwnNote> notes = [];
    final List<SelectedNote> unparseableNotes = [];

    // Get note owner
    final String noteOwner = await getWebId() ?? '';

    // Get file list in owner's Pod
    fileList = await NoteFileHelper().scanFileListDirectory();

    // Create a list of future functions for reading pod and
    // getting fileUrl
    List<Future<String>> futuresFileUrl = [];
    List<Future<String>> futuresNoteContentResult = [];
    for (final fileName in fileList) {
      futuresFileUrl.add(
        filenameToResourceUrl(
          fileName: fileName,
        ),
      );
      futuresNoteContentResult.add(
        readPod(fileName),
      );
    }

    // Read note file content and fetch file Urls
    List<String> fileUrls = await Future.wait(futuresFileUrl);
    List<String> noteContentResults =
        await Future.wait(futuresNoteContentResult);

    // Retrieve note data
    for (int i = 0; i < fileList.length; i++) {
      // Extract ttl data to content data of notes object
      if (noteContentResults[i].isNotEmpty) {
        try {
          // Extract note from turtle string
          final NoteContent? content;
          content = TurtleSerializer.noteFromTurtle(
            noteContentResults[i],
          );

          if (content != null) {
            // Add note content data to note objects list
            notes.add(
              OwnNote(
                noteFileName: fileList[i],
                noteUrl: fileUrls[i],
                noteOwner: noteOwner,
                content: content,
              ),
            );
          } else {
            // Found unparseable file content
            // Add note that failed parsing to bad notes list
            unparseableNotes.add(
              SelectedNote(
                noteFileName: fileList[i],
                noteUrl: fileUrls[i],
                noteOwner: noteOwner,
              ),
            );
            debugPrint('Found unparseable file: ${fileList[i]}');
          }
        } catch (e) {
          // Error deserializing note content
          debugPrint(e.toString());
        }
      } else {
        // If empty, add to unparseable file object list
        unparseableNotes.add(
          SelectedNote(
            noteFileName: fileList[i],
            noteUrl: fileUrls[i],
            noteOwner: noteOwner,
          ),
        );
        debugPrint('Found empty file: ${fileList[i]}');
      }
    }

    if (unparseableNotes.isNotEmpty) {
      debugPrint('Found ${unparseableNotes.length} unparseable or empty files');
    } else {
      debugPrint('All owners files parsed successfully!');
    }

    // Fetch permission lists of who each note is shared with
    try {
      final List<OwnNote> fullNotes;
      final OwnNotesCallResult results;

      final List<String> fileList =
          notes.map((note) => note.noteFileName).toList();

      final Map<dynamic, dynamic> permissionMaps = await readPermissionFileList(
        fileList: fileList,
      );

      fullNotes = notes.addAuthUserLists(permissionMaps: permissionMaps);

      results = OwnNotesCallResult(
        notes: fullNotes,
        unparseableNotes: unparseableNotes,
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint('[getOwnNoteList] Load time: ${duration.inMilliseconds} ms');

      return results;
    } catch (e) {
      // Error retrieving permission lists of each note
      debugPrint(e.toString());
      rethrow;
    }
  } catch (e) {
    // Error finding files
    debugPrint(e.toString());
    rethrow;
  }
}

/// Get data object of externally owned notes shared with the user.
///
/// Arguments:
/// - [hasCurrentAccess] - Flag describing whether user has current
/// access (ie. not revoked) to external file. If false, all files
/// which the user has or has previously been granted access will be returned. (Default: true, ie. only returns list of external notes
/// that user has current access to.
///
/// Returns: [ExternalNotesCallResult] object comprising:
/// - [notes] - list of [ExternalNote] note objects.
/// - [unparseableNotes] - list of [SelectedNote] objects of
/// unparseable notes.
/// - [nonExistentNotes] - list of non-existent [ExternalNote] note
/// objects, if external files were deleted by their owner without
/// first revoking access to the user (and other recipients).

Future<ExternalNotesCallResult> getExternalNoteList({
  bool hasCurrentAccess = true,
}) async {
  final startTime = DateTime.now();

  final List<ExternalNote> notes = [];
  // Build list of external notes shared to user

  final Map<dynamic, dynamic> externalNotesLog;

  externalNotesLog = await NoteFileHelper().scanPermLogFile();

  // final List<ExternalNote> notes = [];
  List<String> unparseableLogRecords = [];

  if (externalNotesLog.isNotEmpty) {
    for (final fileUrl in externalNotesLog.keys) {
      // Each log record of an external file
      final Map<PermissionLogLiteral, dynamic> logRecordOfFile =
          externalNotesLog[fileUrl] as Map<PermissionLogLiteral, dynamic>;

      // Ignore log records of files where access has been
      // revoked
      if (hasCurrentAccess &&
          logRecordOfFile[PermissionLogLiteral.type] == 'revoke') {
        continue;
      }

      // Deserialise external note log record
      try {
        final ExternalNote? note;

        // Extract log record of each external note
        // where user currently has access
        note = NoteFileHelper.extFileDetailsFromLog(
          logRecordOfFile: logRecordOfFile,
          fileUrl: fileUrl,
        );

        if (note != null) {
          // Add log details of note to ExternalNote objects list
          notes.add(note);
        } else {
          // Found unparseable log record
          // Add to unparseable notes list
          unparseableLogRecords.add(fileUrl);
        }
      } catch (e) {
        // Error deserializing external note log record
        debugPrint(e.toString());
      }
    }
  }

  if (unparseableLogRecords.isNotEmpty) {
    debugPrint(
      'Found external files with unparseable log records: $unparseableLogRecords',
    );
  } else {
    debugPrint('All log records of external file parsed successfully!');
  }

  // Fetch and deserialize external note content
  // or count bad files according to error type
  try {
    final List<ExternalNote> fullNotes = [];
    final List<ExternalNote> nonExistentNotes = [];
    final List<SelectedNote> unparseableNotes = [];
    final ExternalNotesCallResult results;

    if (notes.isNotEmpty) {
      // Create a list of future functions for reading external Pods
      List<Future<dynamic>> futuresExtNoteContentResult = [];
      for (final note in notes) {
        futuresExtNoteContentResult.add(
          getExternalNoteContent(
            note: note,
          ),
        );
      }

      List<dynamic> extNoteWithContentResults =
          await Future.wait(futuresExtNoteContentResult);

      // Retrieve note data
      for (int i = 0; i < notes.length; i++) {
        if (extNoteWithContentResults[i] == FileCallStatus.parsingFail) {
          unparseableNotes.add(
            SelectedNote(
              noteFileName: notes[i].noteFileName,
              noteUrl: notes[i].noteUrl,
              noteOwner: notes[i].noteOwner,
            ),
          );
        } else if (extNoteWithContentResults[i] ==
            FileCallStatus.fileNotExists) {
          nonExistentNotes.add(notes[i]);
        } else if (extNoteWithContentResults[i] != null) {
          // Add note content data to note objects list
          fullNotes.add(extNoteWithContentResults[i]);
        }
      }
    }

    results = ExternalNotesCallResult(
      notes: fullNotes,
      nonExistentNotes: nonExistentNotes,
      unparseableNotes: unparseableNotes,
    );

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    debugPrint(
      '[getExternalNoteList] Load time: ${duration.inMilliseconds} ms',
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
/// - [note] - [ExternalNote] note object containing note content.
/// - [FileCallStatus] - where [FileCallStatus] captures read failures
/// including [FileCallStatus.fileNotExists] and
/// [FileCallStatus.parsingFail].

Future<dynamic> getExternalNoteContent({
  required ExternalNote note,
}) async {
  try {
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
    debugPrint('Exception details: $e');
    rethrow;
  }
}
