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
import 'package:notepod/models/own_notes_call_result.dart';
import 'package:notepod/models/own_note.dart';
import 'package:notepod/utils/turtle/note_serializer.dart';

/// Get the list of user's notes object.
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
/// - [notesMap] - map of notes data.
/// - [badFiles] - list of unreadable files.

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
        String noteContent =
            await readPod('$basePath/$fileName', context, childPage);

        // Extract ttl data to notesMap
        if (noteContent.isNotEmpty) {
          try {
            // Extract note from turtle string
            final Note? note;
            note = TurtleSerializer.noteFromTurtle(noteContent);

            if (note != null) {
              // Add note data to notes list
              notes.add(OwnNote(noteFileName: fileName, content: note));
            } else {
              // Found unparseable file content
              // Add note that failed parsing to bad notes map
              badFiles.add(fileName);
              debugPrint('Found unparseable file: $fileName');
            }
          } catch (e) {
            // Error deserializing note
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

    // Fetch permission lists
    try {
      List<OwnNote> fullNotes;
      OwnNotesCallResult results;

      // Convert to map of maps with filename as key
      final Map<String, Map<String, dynamic>> nestedNoteMaps;
      nestedNoteMaps = notes.toMap();

      if (!context.mounted) return OwnNotesCallResult();
      // Get the authorised users of notes
      final tmpMapOfMaps = await getAccessLists(
        nestedNoteMaps,
        // notesMap, // notes,
        context,
        childPage,
        isFilePath: false,
      ) as Map<String, Map<String, dynamic>>;
      // Convert to list of notes (including authorised users)
      fullNotes = mapOfMapsToListOwnNote(tmpMapOfMaps);

      debugPrint('Retrieved permission lists of owners files');

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
/// - [filesWithGrantAccess] - Boolean defines whether retrieving files
/// which user currently has granted access. If false, all files
/// which the user has or has previously been granted access will be returned. (Default: true).

Future<List<ExternalNote>?> getExtNotes({
  required BuildContext context,
  required Widget childPage,
  bool filesWithGrantAccess = true,
}) async {
  try {
    final Map<dynamic, dynamic> sharedNotesLogMap;

    if (!context.mounted) return null;
    sharedNotesLogMap = await NoteFileHelper()
        .scanPermLogFile(context: context, childPage: childPage);

    final List<ExternalNote> notes = [];
    List<String> badFiles = [];

    if (sharedNotesLogMap.isNotEmpty) {
      for (final fileUrl in sharedNotesLogMap.keys) {
        final sharingMetadata = sharedNotesLogMap[fileUrl];

        // Extract details of external files with permissions
        // granted to the user in the latest log entry by
        // selecting for [filesWithGrantAccess] = true
        if (filesWithGrantAccess &&
            sharingMetadata[PermissionLogLiteral.type] == 'revoke') {
          continue;
        }

        try {
          final ExternalNote? note;

          // Parse external note file details
          note = NoteFileHelper.extFileDetailsFromLog(
            sharingMetadata: sharingMetadata,
            fileUrl: fileUrl,
          );

          if (note != null) {
            // Add external note details to notes map.
            // sharedNotesMap[fileUrl] = note;
            notes.add(note);
          } else {
            // Found external note file with unparseable permissions details
            // Add to bad notes map
            badFiles.add(fileUrl);
          }
        } catch (e) {
          // Error deserializing external note permissions
          debugPrint(e.toString());
        }
      }
    }

    if (badFiles.isNotEmpty) {
      debugPrint(
        'Unparseable permission details of files: ${badFiles.toString()}',
      );
    } else {
      debugPrint('All external file details parsed successfully!');
    }

    // return sharedNotesMap;
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
/// ListExternalNotesScreen(), fullNote: _note!,)`
///
/// Arguments:
/// - [context] - The build context.
/// - [childPage] - The widget return page.
/// - [fullNote] - The externally owned note data object including metadata.

Future<FoundExternalNote?> getSharedNoteContent({
  required BuildContext context,
  required Widget childPage,
  required FoundExternalNote fullNote,
}) async {
  try {
    String badFile;

    // final sharedNoteUrl = sharedNoteData[noteUrlPred];

    // Get note content
    // final noteContent =
    //     await readExternalPod(sharedNoteUrl, context, childPage);
    final noteContent =
        await readExternalPod(fullNote.noteUrl, context, childPage);

    // Extract external note ttl data to notesContent
    if (noteContent == SolidFunctionCallStatus.notLoggedIn) {
      debugPrint(
        'readExternalPod() returned ${SolidFunctionCallStatus.notLoggedIn.toString()}',
      );
      // return {};
      return null;
    } else if (noteContent == null || noteContent == {}) {
      // Occurs if sharedNoteUrl file does not exist
      badFile = fullNote.noteUrl; // sharedNoteUrl;
      debugPrint('File not found or empty: $badFile');
      // return {};
      return null;
    } else {
      // noteContent.isNotEmpty
      try {
        // final Map<String, dynamic>? note;
        final Note? note;
        note = TurtleSerializer.noteFromTurtle(noteContent);

        if (note != null) {
          // Add note data to notes map.
          // noteContentMap = note.toJson();
          debugPrint('External file content retrieved successfully');
          fullNote.content = note;
          // return noteContentMap;
          // return note.toJson();
          return fullNote;
        } else {
          // Found external note file with unparseable note content
          badFile = fullNote.noteUrl; // sharedNoteUrl;
          // return {};
          return null;
        }
      } catch (e) {
        // Error deserializing note
        badFile = fullNote.noteUrl; // sharedNoteUrl;
        debugPrint('Error deserializing note $badFile');
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
