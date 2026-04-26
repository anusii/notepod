/// Data models for result of get notes future call.
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Monday 2025-10-06 14:42:01 +1100 Graham Williams>
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

import 'package:notepod/models/note.dart';
import 'package:notepod/models/selected_note.dart';

/// Data model for result of get notes list future call

class NotesCallResult {
  List<Note>? notes;
  List<SelectedNote>? unparseableNotes;
  List<Note>? nonExistentNotes;

  NotesCallResult({
    this.notes = const [],
    this.unparseableNotes = const [],
    this.nonExistentNotes = const [],
  });
}

/// Extension class for NoteCallResult objects

extension NotesCallResultExtension on NotesCallResult {
  /// Method to add lists within two NoteCallResults objects.
  ///
  /// Arguments:
  /// - [results] - Second notes call results object to add to the first notes call results object.

  NotesCallResult addCallResults({required NotesCallResult results}) {
    // Initialise combined results object with mutable copies of the lists.
    // Supports scenarios where users have own notes, notes shared by others
    // or only one or both of those conditions.
    // By adding support for scenario when objects inside NotesCallResult
    // are initially empty, such as if a user does not have any of their
    // own notes but does have notes that others have shared to them.
    NotesCallResult combinedResults = NotesCallResult(
      notes: List.of(notes ?? []),
      unparseableNotes: List.of(unparseableNotes ?? []),
      nonExistentNotes: List.of(nonExistentNotes ?? []),
    );

    // Add notes lists
    if (results.notes!.isNotEmpty) {
      combinedResults.notes!.addAll(results.notes!);
    }

    // Add unparseableNotes lists
    if (results.unparseableNotes!.isNotEmpty) {
      combinedResults.unparseableNotes!.addAll(results.unparseableNotes!);
    }

    // Add nonExistentNotes lists
    if (results.nonExistentNotes!.isNotEmpty) {
      combinedResults.nonExistentNotes!.addAll(results.nonExistentNotes!);
    }

    return combinedResults;
  }
}
