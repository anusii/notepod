/// DESCRIPTION
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/utils/encryption.dart';
import 'package:notepod/utils/rdf.dart';

/// Get the map comprising the list of notes and their data to return notesMap.
/// Parameters:
///   [childPage] is the child widget to return to
Future<Map<String, dynamic>> getNoteList(
  BuildContext context,
  Widget childPage,
) async {
  final List<String> fileList;

  // Get list of files in user's Pod
  fileList = await getResources(context, childPage);

  try {
    String webId = await getWebId() as String;
    webId = webId.replaceAll(profCard, '');

    Map<String, dynamic> notesMap = {};
    // Loop through file list to retrieve note data
    // for each file
    for (final fileName in fileList) {
      // Read file content
      if (context.mounted) {
        String noteContent =
            await readPod(fileName.replaceAll(webId, ''), context, childPage);
        //debugPrint('NoteInfoMap: $fileName');
        notesMap[fileName] = noteInfoMap(noteContent);
        //debugPrint('$fileName => ${notesMap[fileName]}');
      }
    }
    return notesMap;
  } on Object catch (e) {
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
    final rdfMap = parseTTLMap(noteContent);

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

    // Create note info map
    Map noteInfoMap = {
      noteTitlePred: rdfMap[meKey]['$notepodTerms$noteTitlePred'].first,
      createdDateTimePred:
          rdfMap[meKey]['$notepodTerms$createdDateTimePred'].first,
      modifiedDateTimePred:
          rdfMap[meKey]['$notepodTerms$modifiedDateTimePred'].first,
      noteContentPred: decryptVal(
        rdfMap[meKey]['$notepodTerms$noteContentPred'].first,
        rdfMap[meKey]['$notepodTerms$createdDateTimePred'].first,
      ),
    };

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
  final loggedIn = await loginIfRequired(context);
  String webId = await getWebId() as String;
  webId = webId.replaceAll(profCard, '');

  if (loggedIn && context.mounted) {
    Map sharedNotesLogMap = await sharedResources(context, childPage);

    Map sharedNotesMap = {};

    if (sharedNotesLogMap.isNotEmpty) {
      for (final sharedFilaUrl in sharedNotesLogMap.keys) {
        final sharedFileDetails = sharedNotesLogMap[sharedFilaUrl];

        // If [filesWithGrantAccess] is set to true record only the files
        // with grant permission as the latest log entry
        if (filesWithGrantAccess &&
            sharedFileDetails[PermissionLogLiteral.type] == 'revoke') {
          continue;
        }

        sharedNotesMap[sharedFilaUrl] = {
          sharedTime: sharedFileDetails[PermissionLogLiteral.logtime],
          noteUrl: sharedFileDetails[PermissionLogLiteral.resource],
          noteFileName: sharedFilaUrl.split('/').last,
          noteOwner: sharedFileDetails[PermissionLogLiteral.owner],
          permissionGranter: sharedFileDetails[PermissionLogLiteral.granter],
          permissionRecepient:
              sharedFileDetails[PermissionLogLiteral.recepient],
          permissionType: sharedFileDetails[PermissionLogLiteral.type],
          permissionList: sharedFileDetails[PermissionLogLiteral.permissions],
        };
      }
    }

    return sharedNotesMap;
  } else {
    return {};
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
  final sharedNoteUrl = sharedNoteData[noteUrl];

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
