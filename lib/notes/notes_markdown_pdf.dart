/// Markdown → PDF widget conversion for NotePod note exports.
///
/// Converts a Markdown string into a list of `pw.Widget`s for embedding in a
/// printing-package PDF document. Extracted from import_export_screen.dart to
/// keep that file maintainable.
///
// Time-stamp: <2026-06-12>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:notepod/models/own_note.dart';

/// Build the notes PDF bytes for [notes]. Uses Noto Sans so characters
/// outside basic Latin render without the pdf package falling back to
/// Helvetica (which has no Unicode support).
Future<Uint8List> buildNotesPdf(List<OwnNote> notes) async {
  final dateStr = DateFormat('d MMMM yyyy').format(DateTime.now());

  // Sort entries alphabetically by title (case-insensitive), falling back to
  // the filename when a note has no title.
  String sortKey(OwnNote n) =>
      (n.content?.noteTitle ?? n.noteFileName).toLowerCase();
  final sorted = [...notes]..sort((a, b) => sortKey(a).compareTo(sortKey(b)));

  final base = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final italic = await PdfGoogleFonts.notoSansItalic();
  final boldItalic = await PdfGoogleFonts.notoSansBoldItalic();

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(
      base: base,
      bold: bold,
      italic: italic,
      boldItalic: boldItalic,
    ),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'NotePod - Notes Export',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Generated $dateStr  ·  '
            '${notes.length} note${notes.length == 1 ? '' : 's'}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.Divider(),
          pw.SizedBox(height: 4),
        ],
      ),
      build: (_) => [
        for (final note in sorted) ...[
          pw.Text(
            note.content?.noteTitle ?? note.noteFileName,
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          if (note.content?.createdDateTime.isNotEmpty == true)
            pw.Text(
              'Created: ${note.content!.createdDateTime}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          pw.SizedBox(height: 6),
          ...markdownToPdf(note.content?.noteContent ?? ''),
          pw.SizedBox(height: 12),
          // Clear horizontal rule between entries for visual separation.
          pw.Divider(thickness: 1.5, color: PdfColors.grey600),
          pw.SizedBox(height: 12),
        ],
      ],
    ),
  );

  return doc.save();
}

List<pw.Widget> markdownToPdf(String markdown) {
  // Convert GFM task list syntax to readable ASCII before parsing,
  // since the basic markdown parser doesn't handle checkboxes.
  final preprocessed = markdown
      .replaceAll(RegExp(r'- \[x\]', caseSensitive: false), '- [x]')
      .replaceAll('- [ ]', '- [ ]');
  final doc = md.Document(encodeHtml: false);
  final nodes = doc.parseLines(preprocessed.split('\n'));
  final widgets = <pw.Widget>[];
  for (final node in nodes) {
    widgets.addAll(nodeToWidgets(node));
  }
  return widgets;
}

List<pw.Widget> nodeToWidgets(md.Node node) {
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
            textContent(node),
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
            textContent(node),
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
            textContent(node),
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
                  ...(nodeToWidgets(child)),
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
              textContent(node),
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
            ...(nodeToWidgets(child)),
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
String textContent(md.Node node) {
  if (node is md.Text) return node.text;
  if (node is md.Element) {
    return (node.children ?? <md.Node>[]).map(textContent).join();
  }
  return '';
}
