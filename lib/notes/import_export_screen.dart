/// ImportExportScreen — import from JSON and export to JSON / PDF.
///
// Time-stamp: <Saturday 2026-07-18 20:43:18 +1000 Graham Williams>
///
/// Copyright (C) 2023-2026, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

// Add the library directive as we have doc entries above. We publish the above
// meta doc lines in the docs.

library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:notepod/models/notes_call_result.dart';
import 'package:notepod/models/own_note.dart';
import 'package:notepod/notes/import_export_widgets.dart';
import 'package:notepod/notes/notes_io.dart';
import 'package:notepod/notes/notes_markdown_pdf.dart';
import 'package:notepod/services/note_service.dart';
import 'package:notepod/widgets/err_card.dart';

// ── Main screen ───────────────────────────────────────────────────────────────

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  /// Notes loaded from the Pod — populated by [_notesFuture].
  late final Future<NotesCallResult> _notesFuture;
  List<OwnNote> _notes = [];

  bool _loading = false;
  String? _exportMsg;
  bool _exportError = false;
  String? _backupMsg;
  bool _backupError = false;
  String? _viewMsg;
  bool _viewError = false;

  @override
  void initState() {
    super.initState();
    _notesFuture = NoteService().getOwnNoteList();
  }

  void _setExportMsg(String msg, {bool error = false}) => setState(() {
        _exportMsg = msg;
        _exportError = error;
      });

  void _setBackupMsg(String msg, {bool error = false}) => setState(() {
        _backupMsg = msg;
        _backupError = error;
      });

  void _setViewMsg(String msg, {bool error = false}) => setState(() {
        _viewMsg = msg;
        _viewError = error;
      });

  String _ts() {
    final now = DateTime.now();
    return '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  // ── JSON export ─────────────────────────────────────────────────────────────

  Future<void> _exportJson() async {
    setState(() {
      _loading = true;
      _backupMsg = null;
    });
    try {
      final bytes = utf8.encode(notesToBackupJson(_notes));
      final fileName = 'notepod_backup_${_ts()}.json';

      if (kIsWeb) {
        _setBackupMsg('File export is not supported on web.', error: true);
        return;
      }
      final savedUri = await FilePicker.saveFile(
        dialogTitle: 'Save JSON backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );
      if (savedUri != null) {
        final savePath = savedUri.scheme == 'file'
            ? savedUri.toFilePath()
            : savedUri.toString();
        _setBackupMsg('Saved to $savePath');
      }
    } catch (e, st) {
      debugPrint('[Export JSON] $e\n$st');
      _setBackupMsg('Export failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── JSON import ─────────────────────────────────────────────────────────────

  Future<void> _importJson() async {
    setState(() {
      _loading = true;
      _backupMsg = null;
    });
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Select NotePod JSON backup',
        type: FileType.any,
      );
      if (file == null) {
        setState(() => _loading = false);
        return;
      }
      final bytes = await file.readAsBytes();
      final counts = await restoreNotesFromJson(bytes, _ts());
      if (counts == null) {
        _setBackupMsg('No notes found in backup.', error: true);
        return;
      }
      _setBackupMsg(
        'Restored ${counts.saved} note${counts.saved == 1 ? '' : 's'} '
        'to your Pod'
        '${counts.skipped > 0 ? ' (${counts.skipped} skipped — '
            'already exist)' : ''}.',
      );
    } catch (e, st) {
      debugPrint('[Import JSON] $e\n$st');
      _setBackupMsg('Import failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Markdown export ─────────────────────────────────────────────────────────

  Future<void> _exportMarkdown() async {
    setState(() {
      _loading = true;
      _exportMsg = null;
    });
    try {
      final bytes = utf8.encode(notesToMarkdown(_notes));
      final fileName = 'notepod_notes_${_ts()}.md';

      if (kIsWeb) {
        _setExportMsg('File export is not supported on web.', error: true);
        return;
      }
      final savedUri = await FilePicker.saveFile(
        dialogTitle: 'Save Markdown file',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['md'],
        bytes: bytes,
      );
      if (savedUri != null) {
        final savePath = savedUri.scheme == 'file'
            ? savedUri.toFilePath()
            : savedUri.toString();
        _setExportMsg('Saved to $savePath');
      }
    } catch (e, st) {
      debugPrint('[Export Markdown] $e\n$st');
      _setExportMsg('Export failed: $e', error: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── PDF view (Markdown-aware) ─────────────────────────────────────────────

  Future<void> _viewPdf() async {
    setState(() {
      _loading = true;
      _viewMsg = null;
    });
    try {
      final pdfBytes = await buildNotesPdf(_notes);
      final pdfName = 'notepod_notes_${_ts()}.pdf';
      if (!mounted) return;
      await showNotesPdfPreview(
        context: context,
        pdfBytes: pdfBytes,
        pdfName: pdfName,
        title: 'Notes',
        onSaveAs: (bytes, name) async {
          final path = await saveNotesPdf(bytes, name);
          if (path == null || !mounted) return;
          if (path.startsWith('error:')) {
            _setViewMsg(path.substring(6), error: true);
          } else {
            _setViewMsg('Saved to $path');
          }
        },
      );
      _setViewMsg('PDF generated.');
    } catch (e, st) {
      debugPrint('[View PDF] $e\n$st');
      _setViewMsg('PDF generation failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NotesCallResult>(
      future: _notesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return errCard(context, 'Could not load notes.');
        }

        // Cache notes for export operations.
        _notes = snapshot.data!.notes ?? [];

        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final count = _notes.length;
    final s = count == 1 ? '' : 's';

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackupSection(
              title: 'Export & Import',
              description:
                  'Save a complete JSON backup of all your notes, or restore '
                  'everything from a previously saved JSON file. '
                  'Also note the encrypted backup option available through '
                  'your profile menu.',
              message: _backupMsg,
              isError: _backupError,
              child: Row(
                children: [
                  MarkdownTooltip(
                    message: '**Export JSON**\n\n'
                        'Save all $count note$s to a NotePod JSON backup file '
                        'on this device. Keep it somewhere safe so you can '
                        'restore everything later.',
                    child: FilledButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Export JSON'),
                      onPressed: _loading ? null : _exportJson,
                    ),
                  ),
                  const SizedBox(width: 12),
                  MarkdownTooltip(
                    message: '**Import JSON**\n\n'
                        'Restore notes from a previously saved NotePod JSON '
                        'backup file.',
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Import JSON'),
                      onPressed: _loading ? null : _importJson,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            BackupSection(
              title: 'View',
              description:
                  'View your notes as a PDF on screen. You can save or print '
                  'from the preview.',
              message: _viewMsg,
              isError: _viewError,
              child: ActionCard(
                icon: Icons.picture_as_pdf_outlined,
                title: 'View as PDF',
                subtitle: 'View all $count note$s as a PDF.',
                loading: _loading,
                onTap: _viewPdf,
              ),
            ),
            const SizedBox(height: 32),
            BackupSection(
              title: 'Export',
              description:
                  'Save a timestamped copy of your $count note$s as Markdown.',
              message: _exportMsg,
              isError: _exportError,
              child: ActionCard(
                icon: Icons.description_outlined,
                title: 'Export to Markdown',
                subtitle: 'Save all $count note$s as a single .md file.',
                loading: _loading,
                onTap: _exportMarkdown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
