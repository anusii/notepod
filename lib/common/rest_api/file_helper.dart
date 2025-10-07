/// File assistance
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Friday 2025-10-03 13:56:10 +1100 Graham Williams>
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

import 'package:notepod/common/rest_api/operations.dart';
import 'package:notepod/constants/paths.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/note.dart';

/// Helper class for note file operations.

class NoteFileHelper with PodOperationsMixin {
  NoteFileHelper();

  /// Scans the note pod directory for note files.
  ///
  /// Arguments: none.
  /// Returns: list of pod owner's files.

  Future<List<String>> scanFileListDirectory() async {
    try {
      final dirUrl = await getDirUrl(basePath);
      final resources = await getResourcesInContainer(dirUrl);

      return resources.files
          .where((f) => f.startsWith(noteFileNamePrefix) && f.endsWith('.ttl'))
          .toList();
    } catch (e) {
      if (!isFileNotFoundError(e) && !isPermissionError(e)) {
        // Error scanning directory.
      }
      return [];
    }
  }

  /// Safely scans the permission log file to retrieve current log entries of external files shared with the user.
  ///
  /// Arguments:
  /// - [context] - The build context.
  /// - [childpage] - The child widget to return to.
  ///
  /// Returns:
  /// - map of external files with filename as key and details of permissions.

  Future<Map<dynamic, dynamic>> scanPermLogFile(
    BuildContext context,
    Widget childPage,
  ) async {
    try {
      // SharedResources() parses log ttl to map
      debugPrint('');
      final latestLogMap = await sharedResources(context, childPage);
      // debugPrint('[scanPermLog] ${latestLogMap.toString()}');

      if (latestLogMap == SolidFunctionCallStatus.notLoggedIn) {
        // sharedResources() failed login
        return {};
      }

      // debugPrint('latestLogMap != SolidFuctionCallStatus');
      // debugPrint('[scanPermLog] ${latestLogMap.toString()}');
      return latestLogMap;
    } catch (e) {
      if (!isFileNotFoundError(e) && !isPermissionError(e)) {
        // Error reading permission log
      }
      debugPrint('Error: $e');
      rethrow;
    }
  }

  /// Parses external note file details from latest log map
  /// entry for note file.
  ///
  /// Arguments:
  /// - [sharedFileDetails] - Map of details of external
  ///                         note file shared to user.
  /// - [sharedFileUrl] - URL of external file shared to user.
  ///
  /// Returns: parsed map of details of external note file.

  static Map<String, dynamic>? extFileDetailsFromLog(
    Map sharedFileDetails,
    String sharedFileUrl,
  ) {
    try {
      String? sharedTime;
      String? noteUrl;
      String? noteFileName;
      String? noteOwner;
      String? permissionGranter;
      String? permissionRecepient;
      String? permissionType;
      String? permissionList;

      // Extract external note details information

      noteFileName = sharedFileUrl.split('/').last;

      for (final entry in sharedFileDetails.entries) {
        final predicate = entry.key.toString();
        final value = entry.value.toString();

        if (predicate.contains(PermissionLogLiteral.logtime.toString())) {
          sharedTime = value;
        } else if (predicate
            .contains(PermissionLogLiteral.resource.toString())) {
          noteUrl = value;
        } else if (predicate.contains(PermissionLogLiteral.owner.toString())) {
          noteOwner = value;
        } else if (predicate
            .contains(PermissionLogLiteral.granter.toString())) {
          permissionGranter = value;
        } else if (predicate
            .contains(PermissionLogLiteral.recepient.toString())) {
          permissionRecepient = value;
        } else if (predicate.contains(PermissionLogLiteral.type.toString())) {
          permissionType = value;
        } else if (predicate
            .contains(PermissionLogLiteral.permissions.toString())) {
          permissionList = value;
        }
      }

      // Create the external note details object

      return ExternalNote(
        sharedTime: sharedTime!,
        noteUrl: noteUrl!,
        noteFileName: noteFileName,
        noteOwner: noteOwner!,
        permissionGranter: permissionGranter!,
        permissionRecepient: permissionRecepient!,
        permissionType: permissionType!,
        permissionList: permissionList!,
      ).toJson();
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }
}
