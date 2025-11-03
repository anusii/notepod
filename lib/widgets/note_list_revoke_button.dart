/// The revoke note list button.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Sunday 2025-11-02 17:28:21 +1100 Graham Williams>
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

import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
// import 'package:notepod/constants/paths.dart';
import 'package:notepod/models/external_note.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/utils/nav_to_child.dart';
import 'package:notepod/widgets/loading_animation.dart';

/// A revoke button widget for updating the log record for a list
/// of notes.
///
/// Arguments:
/// - [nonExistentNotes] - note list of non-existent files.
/// - [childPage] - child widget to return to.

class NoteListRevokeButton extends StatelessWidget {
  final List<ExternalNote> nonExistentNotes;
  final Widget childPage;

  const NoteListRevokeButton({
    super.key,
    required this.nonExistentNotes,
    required this.childPage,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color
      icon: const Icon(
        Icons.delete,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text(Msg.plsConfirm),
              content: Text(
                nonExistentNotes.length > 1
                    ? Msg.confirmRevokeMultiple
                    : Msg.confirmRevoke,
              ),
              actions: [
                // The "Yes" button
                TextButton(
                  onPressed: () async {
                    showAnimationDialog(
                      context,
                      Msg.revokingNote,
                      false,
                    );

                    // Update log with revoke record for each file
                    for (ExternalNote note in nonExistentNotes) {
                      debugPrint(
                        '[RevokeButton] Revoking access to ${note.noteFileName}',
                      );

                      // Call Solidpod function to update user
                      // permission log with a revoke record for
                      // this non-existent file

                      await revokePermissionToDelFile(
                        fileName: note.noteUrl,
                        isFileEncrypted: true,
                        permissionList:
                            note.permissionList.split(',') as List<dynamic>,
                        removerWebId: note.permissionRecepient, // ie. the user
                        ownerWebId: note.noteOwner,
                        granterWebId: note.permissionGranter,
                        isFileUrl: true,
                      );
                    }

                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true)
                          .pop(); // Dismiss the revoking note dialog

                      navToChildPage(context: context, childPage: childPage);
                    }
                  },
                  child: const Text(ButtonLabel.yes),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // Dismiss the revoking note dialog
                  },
                  child: const Text(ButtonLabel.no),
                ),
              ],
            );
          },
        );
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.delete),
          ),
      label: const Text(
        ButtonLabel.revoke,
      ),
    );
  }
}
