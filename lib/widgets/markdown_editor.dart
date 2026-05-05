/// Markdown editor — single-pane editor or preview, fills available space.
///
// Time-stamp: <Wednesday 2026-05-07 09:00:00 +1000 Graham Williams>
///
/// Copyright (C) 2026, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/material.dart';

import 'package:emacs_text_field/emacs_text_field.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';
import 'package:markdown_widget/markdown_widget.dart';

import 'package:notepod/widgets/markdown_theme.dart';

Widget markdownEditor(
  BuildContext context,
  TextEditingController textController,
  FocusNode focusContent,
  String markdownData, {
  bool preview = false,
}) {
  final cs = Theme.of(context).colorScheme;
  final markdownConfig = markdownConfigForContext(context);

  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
    child: preview
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: textController.text.trim().isEmpty
                ? Text(
                    'Nothing to preview.',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : MarkdownBlock(
                    data: textController.text,
                    config: markdownConfig,
                  ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: EmacsTextField(
                  controller: textController,
                  focusNode: focusContent,
                  expands: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write in Markdown…  '
                        'C-k kill · C-y yank · M-f/b word · C-c d date'
                        '  · code blocks need a language: ```python',
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ClipRect(
                child: SizedBox(
                  height: 42,
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Transform.scale(
                      scale: 0.75,
                      alignment: Alignment.centerLeft,
                      child: MarkdownToolbar(
                        useIncludedTextField: false,
                        controller: textController,
                        focusNode: focusContent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
  );
}
