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

import 'package:http/http.dart' as http;
import 'package:solidpod/solidpod.dart';
import 'package:solidpod/src/solid/api/common_permission.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/utils/encryption.dart';
import 'package:notepod/utils/rdf.dart';

// Get the list of notes created by the user.

Future<Map<String, dynamic>> getNoteList(
    BuildContext context, Widget childPage) async {
  final loggedIn = await loginIfRequired(context);
  String webId = await getWebId() as String;
  webId = webId.replaceAll(profCard, '');

  if (loggedIn) {
    final dataDirPath = await getDataDirPath();
    final dataDirUrl = await getDirUrl(dataDirPath);

    // Why do we need the additional `/`? (20250714 gjw)

    final notesDirUrl = '$dataDirUrl/';

    // Check if the directory exists.

    bool resExist = await checkResourceStatus(notesDirUrl, fileFlag: false);

    if (resExist) {
      //debugPrint('Data: $dataDirUrl');
      final res = await getResourcesInContainer(notesDirUrl);
      // debugPrint(res.toString());

      Map<String, dynamic> notesMap = {};
      // Loop through the list of files to get the file names
      for (final fileName in res.files) {
        // Read file content
        //debugPrint('Read: $fileName');
        String noteContent =
            await readPod(fileName.replaceAll(webId, ''), context, childPage);
        //debugPrint('NoteInfoMap: $fileName');
        notesMap[fileName] = noteInfoMap(noteContent);
        //debugPrint('$fileName => ${notesMap[fileName]}');
      }
      // final filteredMap = filterTreatments(treatmentMap, type);
      return notesMap;
    } else {
      debugPrint('WARN: No data directory for the notes: $notesDirUrl.');
      return {};
    }
  } else {
    debugPrint('WARN: Not logged in when finding the list of notes.');
    return {};
  }
}

// Creates and outputs a map containing the content of a note
Map noteInfoMap(String noteContent) {
  // Parse turtle file
  final rdfMap = parseTTLMap(noteContent);

  // Create note info map
  Map noteInfoMap = {
    noteTitlePred: rdfMap[meKey]['$notepodTerms$noteTitlePred'].first,
    createdDateTimePred:
        rdfMap[meKey]['$notepodTerms$createdDateTimePred'].first,
    modifiedDateTimePred:
        rdfMap[meKey]['$notepodTerms$modifiedDateTimePred'].first,
    noteContentPred: decryptVal(
        rdfMap[meKey]['$notepodTerms$noteContentPred'].first,
        rdfMap[meKey]['$notepodTerms$createdDateTimePred'].first),
  };

  return noteInfoMap;
}

// Check if a resource exists in the POD
Future<bool> checkResourceStatus(
  String resUrl, {
  bool fileFlag = true,
}) async {
  final (:accessToken, :dPopToken) = await getTokensForResource(resUrl, 'GET');
  final response = await http.get(
    Uri.parse(resUrl),
    headers: <String, String>{
      'Content-Type': fileFlag ? '*/*' : 'application/octet-stream',
      'Authorization': 'DPoP $accessToken',
      'Link': fileFlag
          ? '<http://www.w3.org/ns/ldp#Resource>; rel="type"'
          : '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"',
      'DPoP': dPopToken,
    },
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    return true;
  } else if (response.statusCode == 404) {
    return false;
  } else {
    debugPrint('WARN: Failed to check resource status.\n'
        'URL: $resUrl\n'
        'ERR: ${response.body}');
    return false;
  }
}

// Get the Map of shared notes with the current user. If [filesWithGrantAccess]
// is set to true, the function will only output notes with grant permission
// access as the latest log entry.
Future<Map> getSharedNotes(BuildContext context, Widget childPage,
    {bool filesWithGrantAccess = true}) async {
  final loggedIn = await loginIfRequired(context);
  String webId = await getWebId() as String;
  webId = webId.replaceAll(profCard, '');

  if (loggedIn) {
    Map sharedNotesLogMap = await sharedResources(context, childPage);

    Map sharedNotesMap = {};

    if (!sharedNotesLogMap.isEmpty) {
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

// Get the content of a shared note
Future<Map> getSharedNoteContent(
    BuildContext context, Widget childPage, Map sharedNoteData) async {
  final sharedNoteUrl = sharedNoteData[noteUrl];

  // Get note content
  final noteContent = await readExternalPod(sharedNoteUrl, context, childPage);

  final noteContentMap = noteInfoMap(noteContent);

  return noteContentMap;
}

/// Get the map of recipient webIDs and their access permission for each files
/// in a map of notes [notesMap].
/// Parameters:
///   [notesMap] is map of filenames to retrieve permissions for.
///   [fileFlag] set to true if the resource is a file, false if the resource is a directory.
///   [child] is the child widget to return to
///   [isFilePath] Set to true if the filename provided is the full path
Future<dynamic> addRecipientList(
  Map<String, dynamic> notesMap,
  BuildContext context,
  Widget childPage, {
  bool fileFlag = true,
  bool isFilePath = true,
}) async {
  final List<String> fileList = notesMap.keys.toList();

  // Read recipients for each file
  for (final fileName in fileList) {
    // 20250726 jm: While not an external file, as the file
    // is a full file path, use isExternalRes true, to avoid
    // readPermission() prepending the filepath.
    dynamic permList = await readPermission(
        fileName, fileFlag, context, childPage,
        isExternalRes: true);

    // Add recipients map to notesMap
    notesMap[fileName][noteRecipientPred] = permList;
  }

  return notesMap;
}
