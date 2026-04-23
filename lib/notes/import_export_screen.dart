/// ImportExportScreen — import from JSON and export to JSON / PDF.
///
// Time-stamp: <Thursday 2026-04-23 10:23:29 +1000 Graham Williams>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:solidui/solidui.dart';

import 'package:notepod/models/note.dart';
import 'package:notepod/models/note_content.dart';
import 'package:notepod/models/own_note.dart';

// ── Action card widget ────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: cs.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
        ),
        trailing: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        onTap: loading ? null : onTap,
      ),
    );
  }
}

// ── Message banner ────────────────────────────────────────────────────────────

class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? cs.errorContainer : cs.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? cs.onErrorContainer : cs.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? cs.onErrorContainer : cs.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────

class ImportExportScreen extends StatefulWidget {
  /// All notes available in the app for export.
  final List<OwnNote> notes;

  /// Called after a successful import so the parent can refresh.
  final VoidCallback? onImported;

  const ImportExportScreen({
    super.key,
    required this.notes,
    this.onImported,
  });

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  bool _loading = false;
  String? _importMsg;
  bool _importError = false;
  String? _exportMsg;
  bool _exportError = false;

  void _setImportMsg(String msg, {bool error = false}) => setState(() {
        _importMsg = msg;
        _importError = error;
      });

  void _setExportMsg(String msg, {bool error = false}) => setState(() {
        _exportMsg = msg;
        _exportError = error;
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
      _exportMsg = null;
    });
    try {
      // Serialise to a simple list of title + content.
      final data = widget.notes.map((n) {
        final c = n.content;
        return {
          'title': c?.noteTitle ?? n.noteFileName,
          'created': c?.createdDateTime ?? '',
          'modified': c?.modifiedDateTime ?? '',
          'content': c?.noteContent ?? '',
          'fileName': n.noteFileName,
          'owner': n.noteOwner,
        };
      }).toList();
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final bytes = utf8.encode(json);
      final fileName = 'notepod_backup_${_ts()}.json';

      if (kIsWeb) {
        _setExportMsg('File export is not supported on web.', error: true);
        return;
      }
      final savePath = await FilePicker.saveFile(
        dialogTitle: 'Save JSON backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (savePath != null) {
        await File(savePath).writeAsBytes(bytes);
        _setExportMsg('Saved to $savePath');
      }
    } catch (e, st) {
      debugPrint('[Export JSON] $e\n$st');
      _setExportMsg('Export failed: $e', error: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── JSON import ─────────────────────────────────────────────────────────────

  Future<void> _importJson() async {
    setState(() {
      _loading = true;
      _importMsg = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Select NotePod JSON backup',
        type: FileType.any,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        _setImportMsg('Could not read file.', error: true);
        setState(() => _loading = false);
        return;
      }
      final List<dynamic> raw = jsonDecode(utf8.decode(bytes));
      _setImportMsg(
        'Loaded ${raw.length} note${raw.length == 1 ? '' : 's'} from '
        '"${file.name}".\n\n'
        'To add these notes to your Pod, paste the content into new notes manually. '
        'Full automated import into the Pod requires Pod write access during this session.',
      );
      widget.onImported?.call();
    } catch (e, st) {
      debugPrint('[Import JSON] $e\n$st');
      _setImportMsg('Import failed: $e', error: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── PDF export ──────────────────────────────────────────────────────────────

  Future<void> _exportPdf() async {
    setState(() {
      _loading = true;
      _exportMsg = null;
    });
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('d MMMM yyyy').format(now);
      final doc = pw.Document();
      final notes = widget.notes;

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'NotePod — Notes Export',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Generated $dateStr  ·  '
                '${notes.length} note${notes.length == 1 ? '' : 's'}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 4),
            ],
          ),
          build: (ctx) => [
            for (final note in notes) ...[
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    note.content?.noteTitle ?? note.noteFileName,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (note.content?.createdDateTime.isNotEmpty == true)
                    pw.Text(
                      'Created: ${note.content!.createdDateTime}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    note.content?.noteContent ?? '',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 8),
                ],
              ),
            ],
          ],
        ),
      );

      final pdfBytes = await doc.save();
      final pdfName = 'notepod_notes_${_ts()}.pdf';

      if (kIsWeb) {
        await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name: pdfName,
        );
        _setExportMsg('PDF ready — use the dialog to save or print.');
        return;
      }
      final savePath = await FilePicker.saveFile(
        dialogTitle: 'Save PDF',
        fileName: pdfName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (savePath != null) {
        await File(savePath).writeAsBytes(pdfBytes);
        _setExportMsg('Saved to $savePath');
      }
    } catch (e, st) {
      debugPrint('[Export PDF] $e\n$st');
      _setExportMsg('PDF export failed: $e', error: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = widget.notes.length;

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Import ──────────────────────────────────────────────────
            Text('Import', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Import notes from a NotePod JSON backup.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            if (_importMsg != null) ...[
              const SizedBox(height: 12),
              _MessageBanner(message: _importMsg!, isError: _importError),
            ],
            const SizedBox(height: 16),
            _ActionCard(
              icon: Icons.upload_file_outlined,
              title: 'Import from JSON',
              subtitle: 'Select a NotePod JSON backup file.',
              loading: _loading,
              onTap: _importJson,
            ),

            // ── Export ──────────────────────────────────────────────────
            const SizedBox(height: 32),
            Text(
              'Export / Backup',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_exportMsg != null) ...[
              const SizedBox(height: 12),
              _MessageBanner(message: _exportMsg!, isError: _exportError),
            ],
            const SizedBox(height: 8),
            Text(
              'Save a timestamped backup of your notes.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            _ActionCard(
              icon: Icons.download_outlined,
              title: 'Export to JSON',
              subtitle:
                  'Saves all $count note${count == 1 ? '' : 's'} as a JSON backup.',
              loading: _loading,
              onTap: _exportJson,
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Export to PDF',
              subtitle:
                  'Save or print $count note${count == 1 ? '' : 's'} as a PDF.',
              loading: _loading,
              onTap: _exportPdf,
            ),
          ],
        ),
      ),
    );
  }
}
