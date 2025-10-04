/// Turtle serialization management
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

import 'package:rdflib/rdflib.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/utils/encryption.dart';
import 'package:notepod/utils/turtle/parsing_utils.dart';

/// Handle Notepod to/from Turtle serialization operations.

class TurtleSerializer {
  /// Parses a note from Turtle content.

  static Map<String, dynamic>? noteFromTurtle(String ttlContent) {
    try {
      // safeParseTtl parses TTL to map

      final triples = TurtleParsingUtils.safeParseTtlToTriple(ttlContent);
      if (triples == null) return null;

      String? noteTitle;
      String? createdDateTime;
      String? modifiedDateTime;
      String? noteContent;

      // Find note resource and extract information.

      for (final subject in triples.keys) {
        final predicates = triples[subject]!;

        for (final predicate in predicates.keys) {
          final values = predicates[predicate]!;

          if (values.isNotEmpty) {
            final value = values.first.toString();
            // debugPrint(
            //   '[noteFromTurtle] predicate: $predicate, value: $values',
            // );

            if (predicate.contains(noteTitlePred)) {
              noteTitle = value;
            } else if (predicate.contains(createdDateTimePred)) {
              createdDateTime = value;
            } else if (predicate.contains(modifiedDateTimePred)) {
              modifiedDateTime = value;
            } else if (predicate.contains(noteContentPred)) {
              noteContent = decryptVal(value, createdDateTime!);
            }
          }
        }
      }

      // Create the note object

      return Note(
        noteTitle: noteTitle!,
        createdDateTime: createdDateTime!,
        modifiedDateTime: modifiedDateTime!,
        noteContent: noteContent!,
      ).toJson();
    } catch (e) {
      return null;
    }
  }
}
