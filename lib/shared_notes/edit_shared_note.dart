/// NotePod - A note taking app with notes shared through private PODs.
///
// Time-stamp: <Wednesday 2025-07-16 14:43:29 +1000 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/widgets/note_edit_scroll_view.dart';

/// A [StatefulWidget] to edit externally owned notes shared to
/// the user.
/// Parameters:
///   [fullNoteData] - is the data of that note, with information
///                    about the owner, person who shared the note
///                    to the user, and the user's access rights
///                    to the note.
class EditSharedNote extends StatefulWidget {
  final Map fullNoteData;

  const EditSharedNote({super.key, required this.fullNoteData});

  @override
  EditSharedNoteState createState() => EditSharedNoteState();
}

class EditSharedNoteState extends State<EditSharedNote>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormBuilderState>();

  TextEditingController? _textController;

  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;

  String data = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController!.text =
        widget.fullNoteData['sharedNoteContent'][noteContentPred];
    // Start listening to changes.
    _textController!.addListener(_renderMarkdown);
    _scrollController = ScrollController();
    _focusNode = FocusNode();
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
    //         saveNote(
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
    _focusNode.dispose(); // Dispose the FocusNode
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
      focusNode: _focusNode,
      data: data,
      prevNoteData: widget.fullNoteData,
      shared: true,
      noteInfo: widget.fullNoteData['sharedNoteInfo'],
    );
  }
}
