/// A stateful widget for editing an externally owned note.
///
// Time-stamp: <Wednesday 2025-07-16 14:43:29 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute
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
/// Authors: Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:notepod/models/external_note.dart';
import 'package:notepod/shared_notes/view_shared_note.dart';
import 'package:notepod/widgets/note_edit_scroll_view.dart';

/// A [StatefulWidget] to edit externally owned notes shared to
/// the user.
///
/// Arguments:
/// - [note] - the externally owned note.

class EditSharedNote extends StatefulWidget {
  final FoundExternalNote note;

  const EditSharedNote({
    super.key,
    required this.note,
  });

  @override
  EditSharedNoteState createState() => EditSharedNoteState();
}

class EditSharedNoteState extends State<EditSharedNote> {
  final formKey = GlobalKey<FormBuilderState>();

  TextEditingController? _textController;

  /// Scroll controller for single child scroll view.
  late final ScrollController _scrollController;

  /// Focus node for note title text field.
  late final FocusNode _focusTitle;

  /// Focus node for note content text field.
  late final FocusNode _focusContent;

  /// Edited note content
  String data = '';

  /// Note
  late final FoundExternalNote _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _textController = TextEditingController();
    _textController!.text = _note.content!.noteContent;
    // Start listening to changes.
    _textController!.addListener(_renderMarkdown);
    _scrollController = ScrollController();
    // Focus node for the title text field
    // If 'TAB' key press, move to note content text field
    _focusTitle = FocusNode(
      onKeyEvent: (FocusNode node, KeyEvent evt) {
        if (evt.logicalKey == LogicalKeyboardKey.tab) {
          if (evt is KeyDownEvent) {
            // Move focus
            _focusContent.requestFocus();
          }
          return KeyEventResult.handled;
        } else {
          return KeyEventResult.ignored;
        }
      },
    );
    // Focus node for the note content markdown editor
    _focusContent = FocusNode();
    // To enable the ENTER => SAVE functionality within a note replace the above
    // line with the following. For now we will stay with current
    // behaviour. (20250714 gjw).
    //
    // _focusNode = FocusNode(
    //   onKeyEvent: (FocusNode node, KeyEvent evt) {
    //     if (!HardwareKeyboard.instance.isShiftPressed &&
    //         evt.logicalKey.keyLabel == 'Enter') {
    //       if (evt is KeyDownEvent) {
    //         // Save note when enter (not shift-enter) pressed
    //         NoteFileHelper().saveNote(
    //             context, _textController!, formKey, widget.fullNoteData, true);
    //       }
    //       return KeyEventResult.handled;
    //     } else {
    //       return KeyEventResult.ignored;
    //     }
    //   },
    // );
  }

  @override
  void dispose() {
    _textController!.dispose(); // Dispose the TextEditingController
    _scrollController.dispose(); // Dispose the ScrollController
    _focusTitle.dispose(); // Dispose the title focus node
    _focusContent.dispose(); // Dispose the content focus node
    super.dispose();
  }

  void _renderMarkdown() {
    setState(() {
      data = _textController!.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NoteEditScrollView(
      formKey: formKey,
      textController: _textController,
      scrollController: _scrollController,
      focusTitle: _focusTitle,
      focusContent: _focusContent,
      childPage: ViewSharedNote(note: _note),
      data: data,
      prevExternalNote: _note,
      noteTitle: _note.content!.noteTitle,
      isExternal: true,
      isExisting: true,
    );
  }
}
