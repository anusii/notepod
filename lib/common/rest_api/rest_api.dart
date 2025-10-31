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
import 'package:notepod/constants/paths.dart';
import 'package:notepod/models/external_note.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/models/own_note.dart';
import 'package:notepod/models/own_notes_call_result.dart';
import 'package:notepod/utils/turtle/note_serializer.dart';

/// Get the list of user's note objects.
///
/// Example:
/// - `_asyncDataFetch = getNoteList(context: context, childPage: ListNotesScreen())`
/// - used to define async function in future call to get user's notes.
///
/// Arguments:
/// - [context] - the build context.
/// - [childPage] - is the child widget to return to.
///
/// Returns: [OwnNotesCallResult] object comprising
/// - [notes] - list of [OwnNote] note objects
/// - [badFiles] - list of filenames of unreadable files.

Future<OwnNotesCallResult> getNoteList({
  required BuildContext context,
  required Widget childPage,
}) async {
  try {
    final List<String> fileList;

    fileList = await NoteFileHelper().scanFileListDirectory();

    final List<OwnNote> notes = [];
    List<String> badFiles = [];

    // Retrieve note data
    for (final fileName in fileList) {
      // Read file content
      if (context.mounted) {
        String noteContentResult =
            await readPod('$basePath/$fileName', context, childPage);

        // Extract ttl data to content data of notes object
        if (noteContentResult.isNotEmpty) {
          try {
            // Extract note from turtle string
            final NoteContent? content;
            content = TurtleSerializer.noteFromTurtle(noteContentResult);

            if (content != null) {
              // Add note content data to note objects list
              notes.add(OwnNote(noteFileName: fileName, content: content));
            } else {
              // Found unparseable file content
              // Add note that failed parsing to bad notes list
              badFiles.add(fileName);
              debugPrint('Found unparseable file: $fileName');
            }
          } catch (e) {
            // Error deserializing note content
            debugPrint(e.toString());
          }
        } else {
          // If empty, add to badFile list
          // Need to also capture files with serialisation errors
          badFiles.add(fileName);
          debugPrint('Found empty file: $fileName');
        }
      }
    }

    if (badFiles.isNotEmpty) {
      debugPrint('Unparseable or empty files: ${badFiles.toString()}');
    } else {
      debugPrint('All owners files parsed successfully!');
    }

    // Fetch permission lists of who each note is shared with
    try {
      List<OwnNote> fullNotes;
      OwnNotesCallResult results;

      // Convert to map of maps with filename as key for
      // passing to solidpod getAccessLists()
      final Map<String, Map<String, dynamic>> noteMaps;
      noteMaps = notes.toMap();

      if (!context.mounted) return const OwnNotesCallResult();
      // Get the authorised users of notes
      final noteMapsWithPermissions = await getAccessLists(
        dataMap: noteMaps,
        context: context,
        child: childPage,
      ) as Map<String, Map<String, dynamic>>;
      // Convert to list of OwnNote note objects (with authorised users added)
      fullNotes = mapOfMapsToListOwnNote(noteMapsWithPermissions);

      if (badFiles.isEmpty) {
        results = OwnNotesCallResult(notes: fullNotes);
      } else {
        results = OwnNotesCallResult(notes: fullNotes, badFiles: badFiles);
      }

      return results;
    } catch (e) {
      // Error retrieving permission lists of each note
      debugPrint(e.toString());
      rethrow;
    }
  } on Object catch (e) {
    // Error finding files
    debugPrint(e.toString());
    rethrow;
  }
}

/// Get data object of externally owned notes shared with the user.
///
/// Arguments:
/// - [context] - The build context.
/// - [childPage] - The child widget to return to.
/// - [hasCurrentAccess] - Flag describing whether user has current
/// access (ie. not revoked) to external file. If false, all files
/// which the user has or has previously been granted access will be returned. (Default: true, ie. only returns list of external notes
/// that user has current access to.

Future<List<ExternalNote>?> getExtNotes({
  required BuildContext context,
  required Widget childPage,
  bool hasCurrentAccess = true,
}) async {
  try {
    final Map<dynamic, dynamic> externalNotesLog;

    if (!context.mounted) return null;
    externalNotesLog = await NoteFileHelper()
        .scanPermLogFile(context: context, childPage: childPage);

    debugPrint('');
    debugPrint('User\'s Permission Log:');

    final List<ExternalNote> notes = [];
    List<String> unparseableLogRecords = [];

    if (externalNotesLog.isNotEmpty) {
      for (final fileUrl in externalNotesLog.keys) {
        // Each log record of an external file
        final Map<PermissionLogLiteral, dynamic> logRecordOfFile =
            externalNotesLog[fileUrl] as Map<PermissionLogLiteral, dynamic>;

        debugPrint('External file: $fileUrl');
        debugPrint(logRecordOfFile.toString());

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
            // Add to bad notes list
            unparseableLogRecords.add(fileUrl);
          }
        } catch (e) {
          // Error deserializing external note log record
          debugPrint(e.toString());
        }

        // Deserialize external note content
      }
    }

    if (unparseableLogRecords.isNotEmpty) {
      debugPrint(
        'Found external files with unparseable log records: $unparseableLogRecords',
      );
    } else {
      debugPrint('All log records of external file parsed successfully!');
    }

    return notes;
  } on Object catch (e) {
    // Error finding files
    debugPrint(e.toString());
    rethrow;
  }
}

/// Get the content of an externally owned note shared with the user.
///
/// Examples:
/// - `_asyncDataFetch = getSharedNoteContent(context: context, childPage:
/// ListExternalNotesScreen(), note: _note!,)`
///
/// Arguments:
/// - [context] - The build context.
/// - [childPage] - The widget return page.
/// - [note] - The externally owned note data object including metadata.

Future<FoundExternalNote?> getSharedNoteContent({
  required BuildContext context,
  required Widget childPage,
  required FoundExternalNote note,
}) async {
  try {
    String badFile;

    // Get decrypted note content from external file
    final noteContentResult =
        await readExternalPod(note.noteUrl, context, childPage);

    // Extract external note ttl data to noteContent
    if (noteContentResult == SolidFunctionCallStatus.notLoggedIn) {
      debugPrint(
        'readExternalPod() returned ${SolidFunctionCallStatus.notLoggedIn.toString()}',
      );
      // return {};
      return null;
    } else if (noteContentResult == null || noteContentResult == {}) {
      // Occurs if sharedNoteUrl file does not exist
      badFile = note.noteUrl; // sharedNoteUrl;
      debugPrint('File not found or empty: $badFile');
      // return {};
      return null;
    } else {
      // noteContentResult.isNotEmpty
      try {
        // Deserialize note context
        final NoteContent? content;
        content = TurtleSerializer.noteFromTurtle(noteContentResult);

        if (content != null) {
          // Add note content data to external notes object
          debugPrint('External file content retrieved successfully');
          note.content = content;
          return note;
        } else {
          // Found external note file with unparseable note content
          badFile = note.noteUrl; // sharedNoteUrl;
          // return {};
          return null;
        }
      } catch (e) {
        // Error deserializing note
        badFile = note.noteUrl; // sharedNoteUrl;
        debugPrint('Error deserializing note content for: $badFile');
        debugPrint(e.toString());
        // return {};
        return null;
      }
    }
  } on Object catch (e) {
    debugPrint('Exception details: $e');
    rethrow;
  }
}
