/// DESCRIPTION
///
// Time-stamp: <Friday 2025-07-17 20:25:18 +1000 Jess Moore>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:markdown_widget/markdown_widget.dart';

import 'package:notepod/widgets/markdown_theme.dart';

// Displays note content with MarkdownBlock(). The optional [context] lets
// the rendered markdown follow the current theme so that fenced code blocks
// and inline code are legible in dark mode rather than keeping the package
// default light background.
// Expanded noteDisplayMarkdown(
Container noteDisplayMarkdown(
  String data, {
  BuildContext? context,
}) {
  final config =
      context == null ? null : markdownConfigForContext(context);
  return Container(
    alignment: Alignment.topLeft,
    padding: const EdgeInsets.all(10),
    // child: SingleChildScrollView(child: MarkdownBlock(data: data))),
    child: MarkdownBlock(data: data, config: config),
  );
  // 20250717 jm Alt method retained for reference
  // MarkdownParse(
  //   data: noteData[noteContentPred],
  //   // onTapHastag: (String name, String match) {
  //   //   // name => hashtag
  //   //   // match => #hashtag
  //   // },
  //   // onTapMention: (String name, String match) {
  //   //   // name => mention
  //   //   // match => #mention
  //   // },
  // )
}
