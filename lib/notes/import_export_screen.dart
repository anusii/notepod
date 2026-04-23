/// ImportExportScreen — import from JSON and export to JSON / PDF.
///
// Time-stamp: <Friday 2026-04-24 05:28:38 +1000 Graham Williams>
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
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/models/notes_call_result.dart';
import 'package:notepod/models/own_note.dart';
import 'package:notepod/widgets/err_card.dart';

// ── Action card ───────────────────────────────────────────────────────────────

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
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  /// Notes loaded from the Pod — populated by [_notesFuture].
  late final Future<NotesCallResult> _notesFuture;
  List<OwnNote> _notes = [];

  bool _loading = false;
  String? _importMsg;
  bool _importError = false;
  String? _exportMsg;
  bool _exportError = false;

  @override
  void initState() {
    super.initState();
    _notesFuture = getOwnNoteList();
  }

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
      final data = _notes
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
      if (mounted) setState(() => _loading = false);
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
        'Read ${raw.length} note${raw.length == 1 ? '' : 's'} from '
        '"${file.name}".\n\n'
        'To restore notes to your Pod, copy the content into new notes.',
      );
    } catch (e, st) {
      debugPrint('[Import JSON] $e\n$st');
      _setImportMsg('Import failed: $e', error: true);
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
      final buf = StringBuffer();
      for (final note in _notes) {
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
      final bytes = utf8.encode(buf.toString());
      final fileName = 'notepod_notes_${_ts()}.md';

      if (kIsWeb) {
        _setExportMsg('File export is not supported on web.', error: true);
        return;
      }
      final savePath = await FilePicker.saveFile(
        dialogTitle: 'Save Markdown file',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['md'],
      );
      if (savePath != null) {
        await File(savePath).writeAsBytes(bytes);
        _setExportMsg('Saved to $savePath');
      }
    } catch (e, st) {
      debugPrint('[Export Markdown] $e\n$st');
      _setExportMsg('Export failed: $e', error: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── PDF export (Markdown-aware) ───────────────────────────────────────────

  Future<void> _exportPdf() async {
    setState(() {
      _loading = true;
      _exportMsg = null;
    });
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('d MMMM yyyy').format(now);
      final notes = _notes;
      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'NotePod - Notes Export',
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
          build: (_) => [
            for (final note in notes) ...[
              // Note title header.
              pw.Text(
                note.content?.noteTitle ?? note.noteFileName,
                style: pw.TextStyle(
                  fontSize: 15,
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
              pw.SizedBox(height: 6),
              // Render Markdown body as formatted pw widgets.
              ..._markdownToPdf(note.content?.noteContent ?? ''),
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
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
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Markdown → pw widget list ─────────────────────────────────────────────

  /// Parses a Markdown string and returns a list of [pw.Widget]s suitable
  /// for use inside a [pw.MultiPage] build list.
  List<pw.Widget> _markdownToPdf(String markdown) {
    // Convert GFM task list syntax to readable ASCII before parsing,
    // since the basic markdown parser doesn't handle checkboxes.
    final preprocessed = markdown
        .replaceAll(RegExp(r'- \[x\]', caseSensitive: false), '- [x]')
        .replaceAll('- [ ]', '- [ ]');
    final doc = md.Document(encodeHtml: false);
    final nodes = doc.parseLines(preprocessed.split('\n'));
    final widgets = <pw.Widget>[];
    for (final node in nodes) {
      widgets.addAll(_nodeToWidgets(node));
    }
    return widgets;
  }

  List<pw.Widget> _nodeToWidgets(md.Node node) {
    if (node is md.Text) {
      final text = node.text.trim();
      if (text.isEmpty) return [];
      return [
        pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 3),
      ];
    }

    if (node is md.Element) {
      switch (node.tag) {
        // ── Headings ────────────────────────────────────────────────────
        case 'h1':
          return [
            pw.SizedBox(height: 6),
            pw.Text(
              _textContent(node),
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 3),
          ];
        case 'h2':
          return [
            pw.SizedBox(height: 5),
            pw.Text(
              _textContent(node),
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 3),
          ];
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          return [
            pw.SizedBox(height: 4),
            pw.Text(
              _textContent(node),
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
          ];

        // ── Paragraph ───────────────────────────────────────────────────
        case 'p':
          final spans = _inlineSpans(node);
          return [
            pw.RichText(
              text: pw.TextSpan(
                children: spans,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.SizedBox(height: 5),
          ];

        // ── Horizontal rule ─────────────────────────────────────────────
        case 'hr':
          return [
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 4),
          ];

        // ── Blockquote ──────────────────────────────────────────────────
        case 'blockquote':
          return [
            pw.Container(
              margin: const pw.EdgeInsets.only(left: 12),
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.grey400, width: 2),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  for (final child in node.children ?? <md.Node>[])
                    ...(_nodeToWidgets(child)),
                ],
              ),
            ),
            pw.SizedBox(height: 4),
          ];

        // ── Code block ──────────────────────────────────────────────────
        case 'pre':
          return [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                _textContent(node),
                style: pw.TextStyle(
                  fontSize: 9,
                  font: pw.Font.courier(),
                ),
              ),
            ),
            pw.SizedBox(height: 5),
          ];

        // ── Lists ────────────────────────────────────────────────────────
        case 'ul':
        case 'ol':
          final isOrdered = node.tag == 'ol';
          final items = (node.children ?? <md.Node>[])
              .whereType<md.Element>()
              .where((e) => e.tag == 'li')
              .toList();
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 16,
                        child: pw.Text(
                          isOrdered ? '${i + 1}.' : '-',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.RichText(
                          text: pw.TextSpan(
                            children: _inlineSpans(items[i]),
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                ],
              ],
            ),
            pw.SizedBox(height: 4),
          ];

        default:
          // Fallback: render children recursively.
          return [
            for (final child in node.children ?? <md.Node>[])
              ...(_nodeToWidgets(child)),
          ];
      }
    }
    return [];
  }

  /// Recursively build inline [pw.TextSpan]s for styled text.
  List<pw.TextSpan> _inlineSpans(md.Node node) {
    if (node is md.Text) {
      if (node.text.isEmpty) return [];
      return [pw.TextSpan(text: node.text)];
    }
    if (node is md.Element) {
      final childSpans = [
        for (final c in node.children ?? <md.Node>[]) ..._inlineSpans(c),
      ];
      switch (node.tag) {
        case 'strong':
          return childSpans
              .map(
                (s) => pw.TextSpan(
                  text: s.text,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              )
              .toList();
        case 'em':
          return childSpans
              .map(
                (s) => pw.TextSpan(
                  text: s.text,
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                ),
              )
              .toList();
        case 'code':
          return childSpans
              .map(
                (s) => pw.TextSpan(
                  text: s.text,
                  style: pw.TextStyle(
                    font: pw.Font.courier(),
                    fontSize: 9,
                    color: PdfColors.grey800,
                  ),
                ),
              )
              .toList();
        default:
          return childSpans;
      }
    }
    return [];
  }

  /// Extract all plain text from a node tree.
  String _textContent(md.Node node) {
    if (node is md.Text) return node.text;
    if (node is md.Element) {
      return (node.children ?? <md.Node>[]).map(_textContent).join();
    }
    return '';
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
    final cs = Theme.of(context).colorScheme;
    final count = _notes.length;

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Import ────────────────────────────────────────────────
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

            // ── Export ────────────────────────────────────────────────
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
              'Save a timestamped backup of your $count note'
              '${count == 1 ? '' : 's'}.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            _ActionCard(
              icon: Icons.download_outlined,
              title: 'Export to JSON',
              subtitle: 'Saves all $count note${count == 1 ? '' : 's'} '
                  'as a JSON backup.',
              loading: _loading,
              onTap: _exportJson,
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.description_outlined,
              title: 'Export to Markdown',
              subtitle: 'Save all $count note${count == 1 ? '' : 's'} '
                  'as a single .md file.',
              loading: _loading,
              onTap: _exportMarkdown,
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Export to PDF',
              subtitle: 'Save or print all $count note${count == 1 ? '' : 's'} '
                  'as a PDF.',
              loading: _loading,
              onTap: _exportPdf,
            ),
          ],
        ),
      ),
    );
  }
}
