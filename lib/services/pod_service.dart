/// File assistance class
///
/// Copyright (C) 2026, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Friday 2026-04-26 13:56:10 +1000 Jess Moore>
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

import 'package:notepod/constants/paths.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/services/operations.dart';

/// Helper class for books file operations.

// class PodService with PodOperationsMixin {
//   PodService();

// }

/// Record type for raw Pod file data returned by [PodService.scanAndReadPodFiles].

typedef PodFileData = ({String fileName, String url, String ttlContent});

/// Helper class for books file operations.

class PodService with PodOperationsMixin {
  PodService();

  /// Scans the app directory in pod for books files.
  ///
  /// Arguments: none.
  /// Returns: list of pod owner's files.

  Future<List<String>> scanFileListDirectory({
    String fileNamePrefix = noteFileNamePrefix,
  }) async {
    try {
      // debugPrint('scanFileListDirectory: ...');
      final dirUrl = await getDirUrl(basePath);
      // debugPrint('dirUrl: $dirUrl');

      final resources = await getResourcesInContainer(dirUrl);

      // debugPrint('resources: ');
      // debugPrint(resources.toString());

      return resources.files
          .where((f) => f.startsWith(fileNamePrefix) && f.endsWith('.ttl'))
          .toList();
    } catch (e) {
      if (!isFileNotFoundError(e) && !isPermissionError(e)) {
        // Error scanning directory.
      }
      return [];
    }
  }

  /// Scans the Pod directory for files with [fileNamePrefix], fetches their
  /// URLs, and reads+decrypts their TTL content.
  ///
  /// Uses the two-phase readPod pattern: the first call is sequential (to
  /// populate IndividualKeyManager._indKeyMap and KeyManager._masterKey);
  /// subsequent calls run in parallel.
  ///
  /// Arguments:
  /// - [fileNamePrefix] - prefix used to filter files in the Pod directory.
  ///
  /// Returns: list of [PodFileData] records, one per matching file.

  Future<List<PodFileData>> scanAndReadPodFiles(String fileNamePrefix) async {
    final fileList =
        await scanFileListDirectory(fileNamePrefix: fileNamePrefix);
    if (fileList.isEmpty) return [];

    // Fetch URLs in parallel (pure URL construction — safe to parallelise).
    final fileUrls = await Future.wait([
      for (final f in fileList) filenameToResourceUrl(fileName: f),
    ]);

    // Read Pod files: first sequential (populates key maps), rest parallel.
    // Per-file failures are caught so a missing key does not abort the load.
    final ttlContents = <String>[];
    try {
      ttlContents.add(await readPod(fileList.first));
    } on Object catch (e) {
      debugPrint('Failed to read ${fileList.first}: $e');
      ttlContents.add('');
    }
    if (fileList.length > 1) {
      ttlContents.addAll(
        await Future.wait([
          for (final f in fileList.skip(1))
            (() async {
              try {
                return await readPod(f);
              } on Object catch (e) {
                debugPrint('Failed to read $f: $e');
                return '';
              }
            })(),
        ]),
      );
    }

    return [
      for (var i = 0; i < fileList.length; i++)
        (
          fileName: fileList[i],
          url: fileUrls[i],
          ttlContent: ttlContents[i],
        ),
    ];
  }

  /// Scans the permission log for external files whose filename starts with
  /// [fileNamePrefix], parses each matching log record using [parseLogRecord],
  /// and returns the successfully parsed results.
  ///
  /// Revoked entries are skipped when [hasCurrentAccess] is true (default).
  /// Entries whose filename does not match [fileNamePrefix] are also skipped,
  /// so books and requests sharing the same log do not interfere.
  ///
  /// Arguments:
  /// - [fileNamePrefix] - prefix used to filter log entries by filename.
  /// - [parseLogRecord] - converts one log record into a [T] object; return
  ///   null to skip a record.
  /// - [hasCurrentAccess] - if true, skip entries with a `revoke` type.
  ///
  /// Returns: list of successfully parsed [T] objects.

  Future<List<T>> scanExternalFileLog<T>({
    required String fileNamePrefix,
    required T? Function({
      required Map logRecordOfFile,
      required String fileUrl,
    }) parseLogRecord,
    bool hasCurrentAccess = true,
  }) async {
    final externalLog = await scanPermLogFile();
    if (externalLog.isEmpty) return [];

    final items = <T>[];

    for (final fileUrl in externalLog.keys) {
      // Filter by filename prefix before parsing the log record.
      if (!fileUrl.toString().split('/').last.startsWith(fileNamePrefix)) {
        continue;
      }

      final logRecord =
          externalLog[fileUrl] as Map<PermissionLogLiteral, dynamic>;

      // Skip revoked entries.
      if (hasCurrentAccess &&
          logRecord[PermissionLogLiteral.type] == 'revoke') {
        continue;
      }

      try {
        final item = parseLogRecord(
          logRecordOfFile: logRecord,
          fileUrl: fileUrl,
        );
        if (item != null) {
          items.add(item);
        } else {
          debugPrint('Unparseable log record for: $fileUrl');
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    return items;
  }

  /// Safely scans the permission log file to retrieve current log entries of external files shared with the user.
  ///
  /// Arguments:
  /// - [context] - The build context.
  /// - [childPage] - The child widget to return to.
  ///
  /// Returns:
  /// - map of external files with filename as key and details of permissions.

  Future<Map<dynamic, dynamic>> scanPermLogFile() async {
    try {
      // SharedResources() parses log ttl to map

      final latestLogMap = await sharedResources();

      if (latestLogMap == SolidFunctionCallStatus.notLoggedIn) {
        // Return empty map if sharedResources() failed login
        return {};
      }

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
  /// - [logRecordOfFile] - Log record of the external
  /// note file shared to user.
  /// - [fileUrl] - URL of external file shared to user.
  ///
  /// Returns: parsed map of details of external note file.

  static Note? extFileDetailsFromLog({
    required Map logRecordOfFile,
    required String fileUrl,
  }) {
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

      noteFileName = fileUrl.split('/').last;
      // debugPrint('noteFileName: $noteFileName');

      for (final entry in logRecordOfFile.entries) {
        final predicate = entry.key.toString();
        final value = entry.value.toString();
        // debugPrint('predicate: $predicate, value: $value');

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

      return Note(
        noteUrl: noteUrl!,
        noteFileName: noteFileName,
        noteOwner: noteOwner!,
        sharedTime: sharedTime!,
        permissionGranter: permissionGranter!,
        permissionRecepient: permissionRecepient!,
        permissionType: permissionType!,
        permissionList: permissionList!,
        isExternalRes: true,
      );
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }
}
