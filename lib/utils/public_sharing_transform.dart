/// Transformers that strip / restore NotePod's per-note inner content
/// encryption when a note is shared with the Public or Authenticated
/// User classes.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
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
/// Authors: Tony Chen

library;

import 'package:flutter/foundation.dart' show debugPrint;

import 'package:solidpod/solidpod.dart'
    show PublicSharingHooks, turtleToTripleMap;

import 'package:notepod/constants/turtle_structures.dart'
    show createdDateTimePred, noteContentPred, notepodTerms;
import 'package:notepod/utils/encryption.dart' show decryptVal, encryptVal;

/// URI of the predicate that holds the encrypted/decrypted note body.

final String _noteContentUri = '$notepodTerms$noteContentPred';

/// URI of the predicate that stores the note's createdDateTime (which is
/// also the key used to encrypt the note body).

final String _createdDateTimeUri = '$notepodTerms$createdDateTimePred';

/// Register the NotePod transformers with solidpod's public-sharing hooks.

void registerNotepodPublicSharingHooks() {
  PublicSharingHooks.onPublicShareDecrypted = decryptInnerNoteContent;
  PublicSharingHooks.onPublicShareRevoked = encryptInnerNoteContent;
}

/// Strip the inner content encryption from a NotePod note TTL after the
/// outer solidpod wrapper has been removed by `decryptFileInPlace`.

Future<String> decryptInnerNoteContent(
  String resourceUrl,
  String content,
) async {
  final pair = _extractNoteContentTriple(content);
  if (pair == null) {
    debugPrint(
      '[notepod-share-hook] no noteContent triple found in "$resourceUrl", '
      'leaving content unchanged',
    );
    return content;
  }

  final ciphertext = pair.value;
  if (ciphertext.isEmpty) {
    return content;
  }

  String plaintext;
  try {
    plaintext = decryptVal(ciphertext, pair.createdDateTime);
  } on Object catch (e) {
    debugPrint(
      '[notepod-share-hook] failed to decrypt noteContent for '
      '"$resourceUrl" (assuming it is already plaintext): $e',
    );
    return content;
  }

  final replaced = _replaceNoteContentLiteral(
    content,
    oldLiteral: pair.rawLiteral,
    newLiteralValue: plaintext,
  );

  if (replaced == content) {
    debugPrint(
      '[notepod-share-hook] noteContent literal could not be located in '
      'the raw TTL for "$resourceUrl"; returning content unchanged',
    );
    return content;
  }

  debugPrint(
    '[notepod-share-hook] decrypted noteContent (${plaintext.length} '
    'plain chars) for "$resourceUrl"',
  );
  return replaced;
}

/// Re-apply the inner content encryption to a NotePod note TTL before the
/// outer solidpod wrapper is restored by `encryptFileInPlace`.

Future<String> encryptInnerNoteContent(
  String resourceUrl,
  String content,
) async {
  final pair = _extractNoteContentTriple(content);
  if (pair == null) {
    debugPrint(
      '[notepod-share-hook] no noteContent triple found in "$resourceUrl", '
      'leaving content unchanged',
    );
    return content;
  }

  // If the value already looks like the base64 ciphertext produced by
  // [encryptVal] (no whitespace, no obvious natural-language characters,
  // and exact base64 alphabet), assume the inner layer is already in
  // place and leave it alone.
  if (_looksLikeInnerCiphertext(pair.value)) {
    debugPrint(
      '[notepod-share-hook] noteContent already encrypted for '
      '"$resourceUrl", skipping re-encryption',
    );
    return content;
  }

  final ciphertext = encryptVal(
    plainText: pair.value,
    encKey: pair.createdDateTime,
  );

  final replaced = _replaceNoteContentLiteral(
    content,
    oldLiteral: pair.rawLiteral,
    newLiteralValue: ciphertext,
  );

  if (replaced == content) {
    debugPrint(
      '[notepod-share-hook] noteContent literal could not be located in '
      'the raw TTL for "$resourceUrl"; returning content unchanged',
    );
    return content;
  }

  debugPrint(
    '[notepod-share-hook] re-encrypted noteContent for "$resourceUrl"',
  );
  return replaced;
}

class _NoteContentPair {
  _NoteContentPair({
    required this.createdDateTime,
    required this.value,
    required this.rawLiteral,
  });

  /// Parsed createdDateTime value (used as the inner-encryption key).

  final String createdDateTime;

  /// Parsed noteContent value (unescaped).

  final String value;

  /// The literal as it appears verbatim in the raw TTL (including the
  /// surrounding quotes). Used for in-place substitution so we do not
  /// need to round-trip the whole TTL through a serialiser.

  final String rawLiteral;
}

_NoteContentPair? _extractNoteContentTriple(String ttl) {
  final map = turtleToTripleMap(ttl);

  String? noteContent;
  String? createdDateTime;

  for (final entry in map.entries) {
    final preds = entry.value;
    final nc = preds[_noteContentUri];
    final cd = preds[_createdDateTimeUri];
    if (nc is String && cd is String) {
      noteContent = nc;
      createdDateTime = cd;
      break;
    }
  }

  if (noteContent == null || createdDateTime == null) {
    return null;
  }

  final raw = _findNoteContentLiteralInTtl(ttl, noteContent);
  if (raw == null) {
    return null;
  }

  return _NoteContentPair(
    createdDateTime: createdDateTime,
    value: noteContent,
    rawLiteral: raw,
  );
}

/// Find the noteContent triple's raw literal (including quotes) inside
/// [ttl]. The parsed [value] is the unescaped form; we still need to
/// locate the actual bytes in the source so we can substitute them.

String? _findNoteContentLiteralInTtl(String ttl, String value) {
  // Match the `noteContent` predicate as a Turtle prefixed name (`:`
  // followed by `noteContent`) so that we do not accidentally pick up
  // a substring of a different predicate such as `encNoteContent`.

  // Standard form emitted by `genNoteTTLStr`: short single-quoted
  // literal on a single line.
  final shortRegex = RegExp(
    r':noteContent\s+("(?:[^"\\]|\\.)*")',
  );
  final shortMatch = shortRegex.firstMatch(ttl);
  if (shortMatch != null) {
    return shortMatch.group(1);
  }

  // Long-quoted variant (in case the file was hand-edited or a future
  // serialiser switches to triple-quoted strings).
  final longRegex = RegExp(
    r':noteContent\s+("""[\s\S]*?""")',
  );
  final longMatch = longRegex.firstMatch(ttl);
  if (longMatch != null) {
    return longMatch.group(1);
  }

  return null;
}

String _replaceNoteContentLiteral(
  String ttl, {
  required String oldLiteral,
  required String newLiteralValue,
}) {
  final escaped = _escapeTurtleShortLiteral(newLiteralValue);
  return ttl.replaceFirst(oldLiteral, '"$escaped"');
}

String _escapeTurtleShortLiteral(String s) {
  return s
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('\t', r'\t');
}

/// Heuristic check: does [value] look like the base64 output of
/// [encryptVal]? Used to avoid encrypting an already-encrypted note
/// during the revoke path.

final RegExp _base64Re = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');

bool _looksLikeInnerCiphertext(String value) {
  if (value.isEmpty) return false;
  if (value.length % 4 != 0) return false;
  return _base64Re.hasMatch(value);
}
