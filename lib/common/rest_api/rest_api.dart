/// DESCRIPTION
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
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/notes_call_result.dart';
import 'package:notepod/utils/turtle/note_serializer.dart';

/// Get the map comprising the list of notes and their data to return notesMap with the note file name as the key.
///
/// Arguments:
/// - [context] - the build context.
/// - [childPage] - is the child widget to return to.
///
/// Returns: [NotesCallResult] object comprising
/// - [notesMap] - map of notes data.
/// - [badFiles] - list of unreadable files.
// Future<Map<String, dynamic>> getNoteList(
Future<NotesCallResult> getNoteList(
  BuildContext context,
  Widget childPage,
) async {
  try {
    final List<String> fileList;

    fileList = await NoteFileHelper().scanFileListDirectory();

    // String webId = await getWebId() as String;
    // webId = webId.replaceAll(profCard, '');

    Map<String, dynamic> notesMap = {};
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
            final Map<String, dynamic>? note;
            note = TurtleSerializer.noteFromTurtle(noteContent);

            if (note != null) {
              // Add note data to notes map.
              notesMap[fileName] = note;
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
      Map<String, dynamic> fullNotesMap = {};
      NotesCallResult results;

      if (!context.mounted) return NotesCallResult();
      fullNotesMap = await getAccessLists(
        notesMap,
        context,
        childPage,
        isFilePath: false,
      );
      debugPrint('Retrieved permission lists of owners files');

      if (badFiles.isEmpty) {
        results = NotesCallResult(notesMap: fullNotesMap);
      } else {
        results = NotesCallResult(notesMap: fullNotesMap, badFiles: badFiles);
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

/// Get the Map of shared notes with the current user. If [filesWithGrantAccess]
/// is set to true, the function will only output notes with grant permission
/// access as the latest log entry.
///
/// Arguments:
/// - [context] - the build context.
/// - [childPage] - is the child widget to return to.
/// - [filesWithGrantAccess] - boolean defining whether
///                 to fetch external notes with current
///                 permissions. (Default: true).
Future<Map> getSharedNotes(
  BuildContext context,
  Widget childPage, {
  bool filesWithGrantAccess = true,
}) async {
  try {
    final Map<dynamic, dynamic> sharedNotesLogMap;

    if (!context.mounted) return {};
    sharedNotesLogMap =
        await NoteFileHelper().scanPermLogFile(context, childPage);

    Map sharedNotesMap = {};
    List<String> badFiles = [];

    if (sharedNotesLogMap.isNotEmpty) {
      for (final sharedFileUrl in sharedNotesLogMap.keys) {
        final sharedFileDetails = sharedNotesLogMap[sharedFileUrl];

        // Extract details of external files with permissions
        // granted to the user in the latest log entry by
        // selecting for [filesWithGrantAccess] = true
        if (filesWithGrantAccess &&
            sharedFileDetails[PermissionLogLiteral.type] == 'revoke') {
          continue;
        }

        try {
          final Map<String, dynamic>? note;

          // Parse external note file details
          note = NoteFileHelper.extFileDetailsFromLog(
            sharedFileDetails,
            sharedFileUrl,
          );

          if (note != null) {
            // Add external note details to notes map.
            sharedNotesMap[sharedFileUrl] = note;
          } else {
            // Found external note file with unparseable permissions details
            // Add to bad notes map
            badFiles.add(sharedFileUrl);
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

    return sharedNotesMap;
  } on Object catch (e) {
    // Error finding files
    debugPrint(e.toString());
    rethrow;
  }
}

/// Get the content of a shared note using the url of the external note which is part of the external note metadata.
///
/// - [context] - The build context.
/// - [childPage] - The widget return page.
/// - [sharedNoteData] - The metadata of an external note.
Future<Map> getSharedNoteContent(
  BuildContext context,
  Widget childPage,
  Map sharedNoteData,
) async {
  try {
    final Map<dynamic, dynamic> noteContentMap;
    String badFile;

    final sharedNoteUrl = sharedNoteData[noteUrlPred];

    // Get note content
    final noteContent =
        await readExternalPod(sharedNoteUrl, context, childPage);

    // Extract external note ttl data to notesContent
    if (noteContent == SolidFunctionCallStatus.notLoggedIn) {
      debugPrint(
        'readExternalPod() returned ${SolidFunctionCallStatus.notLoggedIn.toString()}',
      );
      return {};
    } else if (noteContent == null || noteContent == {}) {
      // Occurs if sharedNoteUrl file does not exist
      badFile = sharedNoteUrl;
      debugPrint('File not found or empty: $badFile');
      return {};
    } else {
      // noteContent.isNotEmpty
      try {
        final Map<String, dynamic>? note;
        note = TurtleSerializer.noteFromTurtle(noteContent);

        if (note != null) {
          // Add note data to notes map.
          noteContentMap = note;
          debugPrint('External file content retrieved successfully');
          return noteContentMap;
        } else {
          // Found external note file with unparseable note content
          badFile = sharedNoteUrl;
          return {};
        }
      } catch (e) {
        // Error deserializing note
        badFile = sharedNoteUrl;
        debugPrint('Error deserializing note $badFile');
        debugPrint(e.toString());
        return {};
      }
    }
  } on Object catch (e) {
    debugPrint('Exception details: $e');
    rethrow;
  }
}
