/// A stateful widget for sharing a note owned by the user.
///
// Time-stamp: <Friday 2026-04-24 05:25:27 +1000 Graham Williams>
///
/// Copyright (C) 2023-2026, Software Innovation Institute, ANU
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
/// Authors: Anushka Vidanage, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/widgets/note_back_button.dart';

/// A [StatefulWidget] for sharing a note owned by the user.
///
/// Arguments:
/// - [noteUrl] - is the name of the note to be shared.
/// - [noteOwner] - is the webId of the note owner.
/// - [backPage] - The widget used by Back button.
/// - [isExternalRes] - Whether the note is externally owned.
/// - [scaffoldController] - Controller for the Solid scaffold.

class ShareNote extends StatefulWidget {
  final String noteUrl;
  final String noteOwner;
  final Widget backPage;
  final bool isExternal;
  final SolidScaffoldController scaffoldController;

  /// Human-readable note title shown in the notification sent to recipients.

  final String? noteTitle;

  const ShareNote({
    super.key,
    required this.noteUrl,
    required this.noteOwner,
    required this.backPage,
    required this.scaffoldController,
    this.isExternal = false,
    this.noteTitle,
  });

  @override
  ShareNoteState createState() => ShareNoteState();
}

class ShareNoteState extends State<ShareNote> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scaffoldController = widget.scaffoldController;
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  NoteBackButton(
                    childPage: widget.backPage,
                    scaffoldController: _scaffoldController,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: GrantPermissionUi(
                      showAppBar: false,
                      resourceNames: [widget.noteUrl],
                      ownerWebId: widget.noteOwner,
                      isExternalRes: widget.isExternal,
                      resourceDisplayName: widget.noteTitle,
                      inviteConfig: inviteOthersConfig,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
