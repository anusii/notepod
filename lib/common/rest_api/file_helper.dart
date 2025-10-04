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

import 'package:solidpod/solidpod.dart';

import 'package:notepod/common/rest_api/operations.dart';
import 'package:notepod/constants/paths.dart';
import 'package:notepod/constants/turtle_structures.dart';

/// Helper class for note file operations.

class NoteFileHelper with PodOperationsMixin {
  NoteFileHelper();

  /// Scans the note pod directory for note files.

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
}
