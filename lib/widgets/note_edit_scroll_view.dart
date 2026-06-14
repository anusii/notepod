/// A widget for creating and editing notes.
///
// Time-stamp: <Wednesday 2026-05-06 07:59:16 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:solidui/solidui.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/widgets/markdown_editor.dart';
import 'package:notepod/widgets/note_back_button.dart';
import 'package:notepod/widgets/note_save_button.dart';

class NoteEditScrollView extends StatefulWidget {
  const NoteEditScrollView({
    super.key,
    required this.formKey,
    required TextEditingController? textController,
    required SolidScaffoldController scaffoldController,
    required FocusNode focusTitle,
    required FocusNode focusContent,
    required this.childPage,
    required this.data,
    this.prevNote,
    this.isExternal = false,
    this.isExisting = false,
    this.noteTitle,
  })  : _textController = textController,
        _scaffoldController = scaffoldController,
        _focusTitle = focusTitle,
        _focusContent = focusContent;

  final GlobalKey<FormBuilderState> formKey;
  final TextEditingController? _textController;
  final SolidScaffoldController _scaffoldController;
  final FocusNode _focusTitle;
  final FocusNode _focusContent;
  final Widget childPage;
  final String data;
  final Note? prevNote;
  final bool isExternal;
  final bool isExisting;
  final String? noteTitle;

  @override
  State<NoteEditScrollView> createState() => _NoteEditScrollViewState();
}

class _NoteEditScrollViewState extends State<NoteEditScrollView> {
  bool _preview = false;

  // Original values for change detection. The Save button is enabled only
  // when the title or content differs from these (for an existing note), or
  // when either is non-empty (for a new note).
  late final String _initTitle;
  late final String _initContent;

  @override
  void initState() {
    super.initState();
    _initTitle = widget.noteTitle ?? '';
    _initContent = widget._textController?.text ?? '';
    // Rebuild when the content changes so the Save button updates live.
    widget._textController?.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget._textController?.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  /// The current title text from the form field (falls back to the initial).
  String get _currentTitle {
    final state = widget.formKey.currentState;
    final value = state?.fields[noteTitlePred]?.value as String?;
    return value ?? _initTitle;
  }

  /// Whether the note has unsaved changes worth enabling Save for.
  bool get _hasChanges {
    final content = widget._textController?.text ?? '';
    if (!widget.isExisting) {
      // New note: enabled once a title or some content has been entered.
      return _currentTitle.trim().isNotEmpty || content.trim().isNotEmpty;
    }
    // Existing note: enabled when title or content differs from the original.
    return _currentTitle != _initTitle || content != _initContent;
  }

  @override
  Widget build(BuildContext context) {
    final currDateStr = widget.isExisting
        ? ''
        : DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Fixed header: date (new only), title, Preview/Edit button ────
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: FormBuilder(
            key: widget.formKey,
            onChanged: () {
              widget.formKey.currentState?.save();
              // Re-evaluate _hasChanges when the title field changes.
              setState(() {});
            },
            autovalidateMode: AutovalidateMode.disabled,
            skipDisabled: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!widget.isExisting)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('Date: $currDateStr', style: titleStyle),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: noteTitlePred,
                        initialValue: widget.noteTitle,
                        autofocus: true,
                        focusNode: widget._focusTitle,
                        decoration: const InputDecoration(
                          labelText: 'Note Title',
                          labelStyle: TextStyle(
                            letterSpacing: 1.5,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                    ),
                    // Preview/Edit toggle — fixed next to title, never moves.
                    TextButton.icon(
                      onPressed: () => setState(() => _preview = !_preview),
                      icon: Icon(
                        _preview ? Icons.edit_outlined : Icons.preview_outlined,
                        size: 16,
                      ),
                      label: Text(_preview ? 'Edit' : 'Preview'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // ── Content fills all remaining space ──────────────────────────────
        Expanded(
          child: markdownEditor(
            context,
            widget._textController!,
            widget._focusContent,
            widget.data,
            preview: _preview,
          ),
        ),
        // ── Fixed bottom action bar ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 5.0,
            children: [
              ...(!widget.isExisting)
                  ? [
                      NoteSaveButton(
                        textController: widget._textController!,
                        formKey: widget.formKey,
                        scaffoldController: widget._scaffoldController,
                        enabled: _hasChanges,
                      ),
                    ]
                  : [
                      NoteSaveButton(
                        textController: widget._textController!,
                        formKey: widget.formKey,
                        scaffoldController: widget._scaffoldController,
                        prevNote: widget.prevNote,
                        isExisting: true,
                        isExternal: widget.isExternal,
                        enabled: _hasChanges,
                      ),
                      NoteBackButton(
                        childPage: widget.childPage,
                        textController: widget._textController,
                        formKey: widget.formKey,
                        scaffoldController: widget._scaffoldController,
                        prevNote: widget.prevNote,
                        isExisting: widget.isExisting,
                        isExternal: widget.isExternal,
                      ),
                    ],
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
