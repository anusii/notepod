/// The Markdown editor widget.
///
/// Copyright (C) 2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:32:47 +1100 Graham Williams>
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
/// Authors: Anushka Vidanage

library;

import 'package:flutter/material.dart';

// import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';

import 'package:notepod/constants/app.dart';

// import 'package:solidpod/solidpod.dart';

// import 'package:notepod/widgets/loading_animation.dart';
// import 'package:notepod/utils/encryption.dart';
// import 'package:notepod/widgets/err_dialogs.dart';
// import 'package:notepod/app_screen.dart';
// import 'package:notepod/constants/turtle_structures.dart';
// import 'package:notepod/constants/app.dart';
// import 'package:intl/intl.dart';
// import 'package:notepod/home.dart';
import 'package:notepod/notes/save_note.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

Container markdownEditor(
    BuildContext context,
    TextEditingController textController,
    FocusNode focusNode,
    String markdownData,
    GlobalKey<FormBuilderState> formKey,
    [Map? prevNoteData]) {
  final cardWidth = (screenWidth(context) / 2) - 20;

  return Container(
    padding: const EdgeInsets.all(10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(
              width: cardWidth,
              child: TextField(
                // autofocus: true,
                controller: textController,
                focusNode: focusNode,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Note Content',
                ),
                onSubmitted: (value) async {
                  await saveNote(
                      context, textController, formKey, prevNoteData);
                },
                textInputAction: TextInputAction.done,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: cardWidth,
              child: MarkdownToolbar(
                useIncludedTextField:
                    false, // Because we want to use our own, set useIncludedTextField to false
                controller: textController, // Add the _controller
                focusNode: focusNode, // Add the _focusNode
              ),
            ),
          ],
        ),
        SizedBox(
          width: 20,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: cardWidth, child: MarkdownBlock(data: markdownData))
          ],
        )
      ],
    ),
  );
}
