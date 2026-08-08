/// Serialisation helpers for NotePod backup (JSON) and Markdown export.
///
/// Pure data-building / parsing logic extracted from import_export_screen.dart
/// so the screen keeps only its UI orchestration.
///
// Time-stamp: <2026-06-12>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'dart:convert';

import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/own_note.dart';
import 'package:notepod/utils/encryption.dart';

/// Build a pretty-printed JSON backup string for [notes].
String notesToBackupJson(List<OwnNote> notes) {
  final data = notes
      .map(
        (n) => {
          'title': n.content?.noteTitle ?? n.noteFileName,
          'created': n.content?.createdDateTime ?? '',
          'modified': n.content?.modifiedDateTime ?? '',
          'content': n.content?.noteContent ?? '',
          'fileName': n.noteFileName,
          'owner': n.noteOwner,
        },
      )
      .toList();
  return const JsonEncoder.withIndent('  ').convert(data);
}

/// Result of restoring a JSON backup: how many notes were written and how
/// many were skipped (missing filename, or already present on the Pod).
class RestoreCounts {
  final int saved;
  final int skipped;
  const RestoreCounts(this.saved, this.skipped);
}

/// Parse [bytes] of a NotePod JSON backup and write each note to the Pod.
///
/// [tsFallback] supplies an encryption key seed when a note has no created
/// timestamp. Returns null if the backup is empty. Throws on malformed JSON.
Future<RestoreCounts?> restoreNotesFromJson(
  List<int> bytes,
  String tsFallback,
) async {
  final List<dynamic> raw = jsonDecode(utf8.decode(bytes));
  if (raw.isEmpty) return null;

  var saved = 0;
  var skipped = 0;
  for (final entry in raw.cast<Map<String, dynamic>>()) {
    final created = entry['created'] as String? ?? '';
    final modified = entry['modified'] as String? ?? '';
    final title = entry['title'] as String? ?? 'Untitled';
    final content = entry['content'] as String? ?? '';
    final fileName = entry['fileName'] as String? ?? '';
    if (fileName.isEmpty) {
      skipped++;
      continue;
    }

    final encContent = encryptVal(
      plainText: content,
      encKey: created.isNotEmpty ? created : tsFallback,
    );
    final ttl = genNoteTTLStr(created, modified, title, encContent);

    try {
      // Tracked so that closing the window waits for a restore in progress.
      await SolidPendingWrites.track(writePod(fileName, ttl));
      saved++;
    } catch (e) {
      // File already exists — skip.
      skipped++;
    }
  }
  return RestoreCounts(saved, skipped);
}

/// Build a single Markdown document combining all [notes].
String notesToMarkdown(List<OwnNote> notes) {
  final buf = StringBuffer();
  for (final note in notes) {
    final c = note.content;
    final title = c?.noteTitle ?? note.noteFileName;
    buf.writeln('# $title');
    buf.writeln();
    if (c?.createdDateTime.isNotEmpty == true) {
      buf.writeln('*Created: ${c!.createdDateTime}*  ');
    }
    if (c?.modifiedDateTime.isNotEmpty == true) {
      buf.writeln('*Modified: ${c!.modifiedDateTime}*');
    }
    buf.writeln();
    buf.writeln(c?.noteContent ?? '');
    buf.writeln();
    buf.writeln('---');
    buf.writeln();
  }
  return buf.toString();
}
