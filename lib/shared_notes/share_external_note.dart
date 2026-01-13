/// A stateful widget for sharing an externally owned note.
///
// Time-stamp: <Friday 2025-10-24 12:01:41 +1100 Graham Williams>
///
/// Copyright (C) 2023-2025, Software Innovation Institute, ANU
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
/// Authors: Anushka Vidanage, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:notepod/models/external_note.dart';
import 'package:notepod/widgets/note_back_button.dart';

/// A [stateful] widget for sharing an externally owned note shared to the user, to share the note with another user.
///
/// Arguments:
/// - [note] - The externally owned note shared to the user.
/// - [scaffoldController] - Controller for the Solid scaffold.
/// - [backPage] - The widget used by Back button.

class ShareExternalNote extends StatefulWidget {
  final ExternalNote note;
  final Widget backPage;
  final SolidScaffoldController scaffoldController;

  const ShareExternalNote({
    super.key,
    required this.note,
    required this.backPage,
    required this.scaffoldController,
  });

  @override
  ShareExternalNoteState createState() => ShareExternalNoteState();
}

class ShareExternalNoteState extends State<ShareExternalNote> {
  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Note
  late final ExternalNote _note;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _note = widget.note;
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
                    // childPage: ListExternalNotesScreen(
                    //   scaffoldController: _scaffoldController,
                    // ),
                    scaffoldController: _scaffoldController,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: GrantPermissionUi(
                      showAppBar: false,
                      resourceName: _note.noteUrl,
                      isExternalRes: true,
                      ownerWebId: _note.noteOwner,
                      granterWebId: _note.permissionGranter,
                      child: ShareExternalNote(
                        note: _note,
                        backPage: widget.backPage,
                        scaffoldController: _scaffoldController,
                      ),
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
