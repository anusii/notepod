/// Markdown editor — single-pane, preview controlled by caller.
///
// Time-stamp: <Tuesday 2026-05-06 09:00:00 +1000 Graham Williams>
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

/// Returns the note editing widget.
///
/// [preview] is controlled by the caller (see [_EditorWithToggle] in
/// note_edit_scroll_view.dart).  When `true` a formatted markdown render is
/// shown; when `false` the [EmacsTextField] editor + toolbar is shown.

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
    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
    child: preview
        ? ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 300),
            child: Container(
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
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EmacsTextField(
                controller: textController,
                focusNode: focusContent,
                minLines: 15,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Write in Markdown…  '
                      'C-k kill · C-y yank · M-f/b word · C-c d date',
                ),
              ),
              const SizedBox(height: 8),
              MarkdownToolbar(
                useIncludedTextField: false,
                controller: textController,
                focusNode: focusContent,
              ),
            ],
          ),
  );
}
