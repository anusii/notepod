/// Shared widgets for the NotePod Backup (import/export) screen.
///
// Time-stamp: <2026-06-12>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';

/// Push a full-screen preview of [pdfBytes]. Sharing is replaced with a Save
/// action that prompts for a filename and location via [onSaveAs]; printing
/// stays available. [title] is the app-bar title.
Future<void> showNotesPdfPreview({
  required BuildContext context,
  required Uint8List pdfBytes,
  required String pdfName,
  required String title,
  required Future<void> Function(List<int> bytes, String name) onSaveAs,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: PdfPreview(
          build: (_) async => pdfBytes,
          pdfFileName: pdfName,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          allowSharing: false,
          actions: [
            PdfPreviewAction(
              icon: const Icon(Icons.save_alt),
              onPressed: (ctx, build, pageFormat) async {
                final bytes = await build(pageFormat);
                await onSaveAs(bytes, pdfName);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Prompt for a filename and location, then write the PDF [bytes] there.
///
/// Returns the saved path on success, null if cancelled, or an 'error:'-
/// prefixed message on failure. On web, falls back to the share sheet.
Future<String?> saveNotesPdf(List<int> bytes, String defaultName) async {
  try {
    if (kIsWeb) {
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: defaultName,
      );
      return null;
    }
    final savePath = await FilePicker.saveFile(
      dialogTitle: 'Save PDF',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (savePath == null) return null;
    await File(savePath).writeAsBytes(bytes);
    return savePath;
  } catch (e, st) {
    debugPrint('[Save PDF] $e\n$st');
    return 'error:Save failed: $e';
  }
}

// ── Action card ───────────────────────────────────────────────────────────────

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
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

// ── Section wrapper ─────────────────────────────────────────────────────────

/// A titled section: heading, description, an optional message banner, then
/// the section's action [child] (a button row or action card).
class BackupSection extends StatelessWidget {
  final String title;
  final String description;
  final String? message;
  final bool isError;
  final Widget child;

  const BackupSection({
    super.key,
    required this.title,
    required this.description,
    required this.message,
    required this.isError,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(description, style: TextStyle(color: cs.onSurfaceVariant)),
        if (message != null) ...[
          const SizedBox(height: 12),
          MessageBanner(message: message!, isError: isError),
        ],
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

// ── Message banner ────────────────────────────────────────────────────────────

class MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const MessageBanner({
    super.key,
    required this.message,
    required this.isError,
  });

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
