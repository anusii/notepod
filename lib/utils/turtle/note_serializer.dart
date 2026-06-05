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

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/note_content.dart';
import 'package:notepod/utils/encryption.dart';
import 'package:notepod/utils/turtle/parsing_utils.dart';

/// Pattern that matches the canonical base64 alphabet (with optional
/// `=` padding). Used as a cheap signal that a `noteContent` literal is
/// likely the ciphertext produced by [encryptVal], as opposed to plain
/// note text that has been written back to the server for public
/// sharing.

final RegExp _base64NoteContentRe = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');

/// Decrypt [value] when it looks like ciphertext produced by
/// [encryptVal] and a key is available. Otherwise return [value]
/// unchanged so that a note left in plaintext (e.g. after public-share
/// decryption) is still treated as a valid, parseable note.

String _decryptIfCiphertext(String value, String? createdDateTime) {
  if (createdDateTime == null) return value;
  final looksLikeCiphertext = value.isNotEmpty &&
      value.length % 4 == 0 &&
      _base64NoteContentRe.hasMatch(value);
  if (!looksLikeCiphertext) return value;

  try {
    return decryptVal(value, createdDateTime);
  } on Object catch (e) {
    debugPrint(
      'noteFromTurtle: noteContent looked like ciphertext but could not '
      'be decrypted, treating as plaintext instead: $e',
    );
    return value;
  }
}

/// Handle Notepod to/from Turtle serialization operations.

class TurtleSerializer {
  /// Parses a note from Turtle content.

  static NoteContent? noteFromTurtle(String ttlContent) {
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
          final value = predicates[predicate]!;

          if (predicate.contains(noteTitlePred)) {
            noteTitle = value;
          } else if (predicate.contains(createdDateTimePred)) {
            createdDateTime = value;
          } else if (predicate.contains(modifiedDateTimePred)) {
            modifiedDateTime = value;
          } else if (predicate.contains(noteContentPred)) {
            noteContent = _decryptIfCiphertext(
              value as String,
              createdDateTime,
            );
          }
        }
      }

      // Create the note object

      return NoteContent(
        noteTitle: noteTitle!,
        createdDateTime: createdDateTime!,
        modifiedDateTime: modifiedDateTime!,
        noteContent: noteContent!,
      );
    } catch (e) {
      return null;
    }
  }
}
