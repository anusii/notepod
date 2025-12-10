/// The Markdown editor widget.
///
/// Copyright (C) 2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:markdown_toolbar/markdown_toolbar.dart';
import 'package:markdown_widget/markdown_widget.dart';

Container markdownEditor(
  BuildContext context,
  TextEditingController textController,
  FocusNode focusContent,
  String markdownData,
) {
  return Container(
    padding: const EdgeInsets.all(10),
    child: Row(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              TextField(
                // autofocus: true,
                controller: textController,
                focusNode: focusContent,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Note Content',
                ),
              ),
              MarkdownToolbar(
                useIncludedTextField:
                    false, // Because we want to use our own, set useIncludedTextField to false
                controller: textController, // Add the _controller
                focusNode: focusContent, // Add the _focusContent
              ),
            ],
          ),
        ),
        Expanded(
          child: MarkdownBlock(data: markdownData),
        ),
      ],
    ),
  );

  // // av: 20250604 - Alternative markdown editor option using
  // // markdown_editor_plus. The current version of this gives some errors
  // // when inputting different styles such as checkboxes.
  // return Container(
  //   padding: const EdgeInsets.all(10),
  //   child: MarkdownAutoPreview(
  //     controller: _textController,
  //     decoration: InputDecoration(
  //       hintText: 'Input markdown text',
  //     ),
  //     emojiConvert: true,
  //     hintText: 'Tap here to start writing a note!',
  //     // maxLines: 10,
  //     // minLines: 1,
  //     // expands: true,
  //   ),
  //   // SplittedMarkdownFormField(
  //   //   controller: _textController,
  //   //   markdownSyntax: '## Headline',
  //   //   decoration: const InputDecoration(
  //   //     hintText: 'Editable text',
  //   //   ),
  //   //   emojiConvert: true,
  //   // )
  // );
}
