/// Theme-aware Markdown config helper for note rendering.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:markdown_widget/markdown_widget.dart';

/// Build a [MarkdownConfig] that follows the current [Theme]'s brightness.

MarkdownConfig markdownConfigForContext(BuildContext context) {
  final theme = Theme.of(context);

  if (theme.brightness == Brightness.light) {
    return MarkdownConfig.defaultConfig;
  }

  // For dark mode pick a surface colour that sits a notch above the
  // scaffold background so code blocks remain visually distinct without
  // glaring against the rest of the page.

  final scheme = theme.colorScheme;
  final codeSurface = scheme.surfaceContainerHighest;
  final codeForeground = scheme.onSurface;

  return MarkdownConfig.darkConfig.copy(
    configs: [
      PreConfig.darkConfig.copy(
        decoration: BoxDecoration(
          color: codeSurface,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          color: codeForeground,
        ),
        styleNotMatched: TextStyle(color: codeForeground),
      ),
      CodeConfig(
        style: TextStyle(
          backgroundColor: codeSurface,
          color: codeForeground,
        ),
      ),
    ],
  );
}
