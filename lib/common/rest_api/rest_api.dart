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
import 'package:notepod/models/note.dart';
import 'package:notepod/utils/encryption.dart';
// import 'package:notepod/utils/operations.dart';
// import 'package:notepod/utils/rdf.dart';
import 'package:notepod/utils/turtle/note_serializer.dart';

/// Get the map comprising the list of notes and their data to return notesMap.
/// Parameters:
///   [childPage] is the child widget to return to
Future<Map<String, dynamic>> getNoteList(
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
            }
          } catch (e) {
            // Error deserializing note
            debugPrint(e.toString());
          }
        } else {
          // If empty, add to badFile list
          // Need to also capture files with serialisation errors
          badFiles.add(fileName);
          debugPrint('[getNoteList] Found empty file: $fileName');
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

      if (!context.mounted) return {};
      fullNotesMap = await getAccessLists(
        notesMap,
        context,
        childPage,
        isFilePath: false,
      );
      debugPrint('Retrieved permission lists of owners files');

      // return notesMap;
      return fullNotesMap;
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

/// Parses note content from turtle format, decrypts the note text, and formats as json map
///
/// - [noteContent] - note content in turtle map format
Map noteInfoMap(String noteContent) {
  try {
    // Parse turtle file
    debugPrint('Before parseTTLMap');
    final rdfMap = parseTTLMap(noteContent);
    debugPrint('After parseTTLMap');

    assert(
      rdfMap.isNotEmpty,
      'rdfMap should not be empty',
    );

    if (rdfMap[meKey] == null) {
      debugPrint(
        '[noteInfoMap() rdfMap[meKey] == null]: ${rdfMap.toString()}',
      );
    }

    assert(
      rdfMap[meKey] != null,
      'rdfMap must have key "#me"',
    );

    assert(
      rdfMap[meKey]['$notepodTerms$noteTitlePred'] != null,
      'rdfMap[meKey] keys must contain $notepodTerms$noteTitlePred',
    );

    // Create note info map
    // Map noteInfoMap = {
    //   noteTitlePred: rdfMap[meKey]['$notepodTerms$noteTitlePred'].first,
    //   createdDateTimePred:
    //       rdfMap[meKey]['$notepodTerms$createdDateTimePred'].first,
    //   modifiedDateTimePred:
    //       rdfMap[meKey]['$notepodTerms$modifiedDateTimePred'].first,
    //   noteContentPred: decryptVal(
    //     rdfMap[meKey]['$notepodTerms$noteContentPred'].first,
    //     rdfMap[meKey]['$notepodTerms$createdDateTimePred'].first,
    //   ),
    // };

    final Note noteInfo;
    noteInfo = Note(
      noteTitle: rdfMap[meKey]['$notepodTerms$noteTitlePred'].first,
      createdDateTime: rdfMap[meKey]['$notepodTerms$createdDateTimePred'].first,
      modifiedDateTime:
          rdfMap[meKey]['$notepodTerms$modifiedDateTimePred'].first,
      noteContent: decryptVal(
        rdfMap[meKey]['$notepodTerms$noteContentPred'].first,
        rdfMap[meKey]['$notepodTerms$createdDateTimePred'].first,
      ),
    );
    final Map<String, dynamic> noteInfoMap = noteInfo.toJson();

    return noteInfoMap;
  } on Object catch (e, s) {
    debugPrint('Exception details:\n $e');
    debugPrint('Stack trace:\n $s');
    rethrow;
  }
}

// Get the Map of shared notes with the current user. If [filesWithGrantAccess]
// is set to true, the function will only output notes with grant permission
// access as the latest log entry.
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
  final sharedNoteUrl = sharedNoteData[noteUrlPred];

  try {
    // Get note content
    final noteContent =
        await readExternalPod(sharedNoteUrl, context, childPage);

    assert(
      noteContent != null &&
          noteContent != {} &&
          noteContent != SolidFunctionCallStatus.notLoggedIn,
      'Note content should not be null or empty or a SolidFunctionCallStatus',
    );

    final noteContentMap = noteInfoMap(noteContent);
    return noteContentMap;
  } on Object catch (e, s) {
    debugPrint('Exception details:\n $e');
    debugPrint('Stack trace:\n $s');
    rethrow;
  }
}
