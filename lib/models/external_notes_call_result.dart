/// Data models for result of get external notes future call.
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Sunday 2025-11-02 13:12:01 +1100 Graham Williams>
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

import 'package:notepod/models/external_note.dart';

/// Data model for result of get external notes list future call

class ExternalNotesCallResult {
  final List<ExternalNote>? notes;
  final List<String>? unparseableFiles;
  final List<String>? nonExistentFiles;

  const ExternalNotesCallResult({
    this.notes = const [],
    this.unparseableFiles = const [],
    this.nonExistentFiles = const [],
  });
}
