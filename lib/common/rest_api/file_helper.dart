/// File assistance class
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Friday 2025-10-03 13:56:10 +1100 Graham Williams>
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

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

import 'package:notepod/common/rest_api/operations.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/paths.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/models/note_content.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/shared_notes/view_shared_note.dart';
import 'package:notepod/utils/encryption.dart';
import 'package:notepod/widgets/err_dialogs.dart';
import 'package:notepod/widgets/loading_animation.dart' as loading;

/// Helper class for note file operations.

class NoteFileHelper with PodOperationsMixin {
  NoteFileHelper();

  /// Scans the note pod directory for note files.
  ///
  /// Arguments: none.
  /// Returns: list of pod owner's files.

  Future<List<String>> scanFileListDirectory() async {
    try {
      final dirUrl = await getDirUrl(basePath);
      final resources = await getResourcesInContainer(dirUrl);

      return resources.files
          .where((f) => f.startsWith(noteFileNamePrefix) && f.endsWith('.ttl'))
          .toList();
    } catch (e) {
      if (!isFileNotFoundError(e) && !isPermissionError(e)) {
        // Error scanning directory.
      }
      return [];
    }
  }

  /// Safely scans the permission log file to retrieve current log entries of external files shared with the user.
  ///
  /// Arguments:
  /// - [context] - The build context.
  /// - [childPage] - The child widget to return to.
  ///
  /// Returns:
  /// - map of external files with filename as key and details of permissions.

  Future<Map<dynamic, dynamic>> scanPermLogFile() async {
    try {
      // SharedResources() parses log ttl to map

      final latestLogMap = await sharedResources();

      if (latestLogMap == SolidFunctionCallStatus.notLoggedIn) {
        // Return empty map if sharedResources() failed login
        return {};
      }

      return latestLogMap;
    } catch (e) {
      if (!isFileNotFoundError(e) && !isPermissionError(e)) {
        // Error reading permission log
      }
      debugPrint('Error: $e');
      rethrow;
    }
  }

  /// Parses external note file details from latest log map
  /// entry for note file.
  ///
  /// Arguments:
  /// - [logRecordOfFile] - Log record of the external
  /// note file shared to user.
  /// - [fileUrl] - URL of external file shared to user.
  ///
  /// Returns: parsed map of details of external note file.

  static Note? extFileDetailsFromLog({
    required Map logRecordOfFile,
    required String fileUrl,
  }) {
    try {
      String? sharedTime;
      String? noteUrl;
      String? noteFileName;
      String? noteOwner;
      String? permissionGranter;
      String? permissionRecepient;
      String? permissionType;
      String? permissionList;

      // Extract external note details information

      noteFileName = fileUrl.split('/').last;
      // debugPrint('noteFileName: $noteFileName');

      for (final entry in logRecordOfFile.entries) {
        final predicate = entry.key.toString();
        final value = entry.value.toString();
        // debugPrint('predicate: $predicate, value: $value');

        if (predicate.contains(PermissionLogLiteral.logtime.toString())) {
          sharedTime = value;
        } else if (predicate
            .contains(PermissionLogLiteral.resource.toString())) {
          noteUrl = value;
        } else if (predicate.contains(PermissionLogLiteral.owner.toString())) {
          noteOwner = value;
        } else if (predicate
            .contains(PermissionLogLiteral.granter.toString())) {
          permissionGranter = value;
        } else if (predicate
            .contains(PermissionLogLiteral.recepient.toString())) {
          permissionRecepient = value;
        } else if (predicate.contains(PermissionLogLiteral.type.toString())) {
          permissionType = value;
        } else if (predicate
            .contains(PermissionLogLiteral.permissions.toString())) {
          permissionList = value;
        }
      }

      // Create the external note details object

      return Note(
        noteUrl: noteUrl!,
        noteFileName: noteFileName,
        noteOwner: noteOwner!,
        sharedTime: sharedTime!,
        permissionGranter: permissionGranter!,
        permissionRecepient: permissionRecepient!,
        permissionType: permissionType!,
        permissionList: permissionList!,
      );
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  /// Safely deletes a note file
  ///
  /// Arguments:
  /// - [context] - The build context.
  /// - [filename] - The note filename. For external notes this should be the note Url.
  /// - [isExternal] - Boolean describing whether the note is an external note. (Default: false).

  Future<void> deleteNote({
    required BuildContext context,
    required String filename,
    required Widget child,
    bool isExternal = false,
  }) async {
    // Delete file
    if (isExternal) {
      try {
        // Delete external file
        await deleteExternalFile(filename);
      } catch (e) {
        // Error deleting external file
        debugPrint('Error deleting to external note: $e');
        rethrow;
      }
    } else {
      try {
        // Resolve the relative path to a full POD URL before calling
        // deleteFile, which expects an absolute URL.

        final fileUrl = await getFileUrl('$basePath/$filename');
        await deleteFile(fileUrl: fileUrl);
      } catch (e) {
        debugPrint('Error deleting user\'s note: $e');
        rethrow;
      }
    }
  }

  /// Function that starts a waiting indicator, calls steps to save note,
  /// and then navigates to the appropriate return page.
  ///
  /// Examples:
  /// - `await saveNote(context: context, textController: textController, formKey: formKey, prevOwnNote: note, isExisting: true)` - to save note
  /// owned by the user.
  /// - `await saveNote(context: context, textController: textController, formKey: formKey, prevExternalNote: note, isExisting: true, isExternal: true)`
  /// - to save an externally owned note.
  ///
  /// - [context] - The build context.
  /// - [textController] - Text controller of the note text content editor.
  /// - [formKey] - Key of the form to edit note metadata.
  ///   [scaffoldController] - Controller for the Solid scaffold.
  /// - [prevExternalNote] - Optional existing external note data object. Required
  /// for saving existing externally owned notes. (Default: null).
  /// - [prevOwnNote] - Optional existing user's note data object. Required
  /// for saving existing notes owned by the user. (Default: null).
  /// - [isExternal] - Optional boolean denoting whether note is externally
  /// owned. (Default: false).
  /// - [isExisting] - Optional boolean denoting whether note already
  /// exists. (Default: false).

  Future<void> saveNote({
    required BuildContext context,
    required TextEditingController textController,
    required GlobalKey<FormBuilderState> formKey,
    required SolidScaffoldController scaffoldController,
    Note? prevExternalNote,
    Note? prevOwnNote,
    bool isExternal = false,
    bool isExisting = false,
  }) async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      // Compares to prevNoteData if previous note data provided
      // Adds sharing metadata if shared==true

      Map formData = formKey.currentState?.value as Map;
      String noteText = textController.text;
      final String prevNoteTitle;
      final String prevNoteContent;
      final Note updatedExternalNote;
      final Note updatedOwnNote;
      final NoteContent updatedContent;

      // Note title need to be spaceless as we are using that name
      // to create a .acl file. And the acl file url cannot have spaces
      String noteTitle = formData[noteTitlePred].replaceAll('\n', '');

      // Get current datetimestamp for mod time and/or creation time
      String modifiedDateTimeStr =
          DateFormat('yyyyMMddTHHmmss').format(DateTime.now()).toString();

      if (isExisting) {
        // Retrieve existing note title and content for comparison
        if (isExternal) {
          prevNoteTitle = prevExternalNote!.content!.noteTitle;
          prevNoteContent = prevExternalNote.content!.noteContent;
        } else {
          prevNoteTitle = prevOwnNote!.content!.noteTitle;
          prevNoteContent = prevOwnNote.content!.noteContent;
        }
        // Compare updated title and content to existing
        // title and content
        if (noteTitle == prevNoteTitle && noteText == prevNoteContent) {
          showErrDialog(context, ErrMsg.noChanges);
        } else {
          // Loading animation
          loading.showAnimationDialog(
            context,
            Msg.savingNote,
            false,
          );

          if (isExternal) {
            // Update content of External note
            try {
              updatedContent = prevExternalNote!.content!.copyWith(
                modifiedDateTime: modifiedDateTimeStr,
                noteTitle: noteTitle,
                noteContent: noteText,
              );
              updatedExternalNote =
                  prevExternalNote.copyWith(content: updatedContent);
            } on Exception catch (e) {
              debugPrint(
                'Exception (formatting update to existing note):\n $e',
              );
              rethrow;
            }

            // Save external note
            try {
              if (!context.mounted) return;

              debugPrint('save external note:');
              debugPrint('noteUrl: ${prevExternalNote.noteUrl}');
              debugPrint('noteFileName: ${prevExternalNote.noteFileName}');
              debugPrint('noteOwner: ${prevExternalNote.noteOwner}');

              // External note
              // Encrypt note, create TTL, update file in POD
              await saveNoteToPod(
                context: context,
                // Use existing file url
                noteUrl: prevExternalNote.noteUrl,
                noteOwner: prevExternalNote.noteOwner,
                data: updatedContent,
                childPage: ViewSharedNote(
                  note: updatedExternalNote,
                  scaffoldController: scaffoldController,
                ),
                scaffoldController: scaffoldController,
                isExternal: isExternal,
              );
            } on Exception catch (e) {
              debugPrint('Exception (saving existing external note):\n $e');
            }
          } else {
            // Update content of Own note
            try {
              updatedContent = prevOwnNote!.content!.copyWith(
                modifiedDateTime: modifiedDateTimeStr,
                noteTitle: noteTitle,
                noteContent: noteText,
              );
              updatedOwnNote = prevOwnNote.copyWith(content: updatedContent);
            } on Exception catch (e) {
              debugPrint(
                'Exception (formatting update to existing note):\n $e',
              );
              rethrow;
            }

            // Save own note
            try {
              if (!context.mounted) return;

              // Edited my note
              // Encrypt note, create TTL, update file in POD
              await saveNoteToPod(
                context: context,
                // Use existing filename
                noteFileName: prevOwnNote.noteFileName,
                data: updatedContent,
                overwrite: true,
                childPage: ViewNote(
                  note: updatedOwnNote,
                  scaffoldController: scaffoldController,
                ),
                scaffoldController: scaffoldController,
              );
            } on Exception catch (e) {
              debugPrint('Exception (saving existing my note):\n $e');
            }
          }
        }
      } else {
        // Newly created note (not editing previous note)

        // Check note content is not empty
        if (noteText.trim() != '') {
          try {
            // Loading animation
            loading.showAnimationDialog(
              context,
              Msg.savingNote,
              false,
            );

            // Create new note data structure
            final newContent = NoteContent(
              createdDateTime: modifiedDateTimeStr,
              modifiedDateTime: modifiedDateTimeStr,
              noteTitle: noteTitle,
              noteContent: noteText,
            );

            // Encrypt note, create TTL and write to file in POD
            if (!context.mounted) return;

            await saveNoteToPod(
              context: context,
              // Create filename
              noteFileName: '$noteFileNamePrefix$modifiedDateTimeStr.ttl',
              data: newContent,
              childPage: ListNotesScreen(
                scaffoldController: scaffoldController,
              ),
              scaffoldController: scaffoldController,
            );
          } on Exception catch (e) {
            debugPrint('Exception (saving new my note):\n $e');
          }
        } else {
          // No note content message
          showErrDialog(context, ErrMsg.noContent);
        }
      }
    } else {
      showErrDialog(
        context,
        ErrMsg.invalidName,
      );
    }
  }

  /// Write note to Pod and navigate to return page or display error dialog
  /// if write to Pod failed to return a successful SolidCallFunctionStatus.
  ///
  /// Examples:
  /// - `await saveNoteToPod(context: context, data: updatedContent, noteFileName: noteFileName, childPage: ListNotesScreen(), scaffoldController: scaffoldController)` - to
  /// save a note owned by the user.
  /// - `await saveNoteToPod(context: context, data: updatedContent,
  /// childPage: ListNotesScreen(), noteUrl: noteUrl, noteOwner: noteOwner,
  /// isExternal: true, scaffoldController: scaffoldController)` - to save an externally owned note.
  ///
  /// - [context] - The build context.
  /// - [data] - The note content data to be encrypted and written to Pod.
  /// - [childPage] - The destination widget to navigate to after note is saved.
  ///   [scaffoldController] - Controller for the Solid scaffold.
  /// - [noteFileName] - Optional filename. Required for saving user's own notes.
  /// - [noteUrl] - Optional note file url. Required for saving notes
  /// that are externally owned.
  /// - [noteOwner] - Optional note owner webId. Required for saving notes
  /// that are externally owned.
  /// - [overwrite] - Optional boolean defining whether updating an existing owner's note.
  /// - [isExternal] - Optional boolean defining whether writing an external note.

  Future<void> saveNoteToPod({
    required BuildContext context,
    required NoteContent data,
    required Widget childPage,
    required SolidScaffoldController scaffoldController,
    String noteFileName = '',
    String noteUrl = '',
    String noteOwner = '',
    bool overwrite = false,
    bool isExternal = false,
  }) async {
    try {
      // Encrypt note text using created time as the key
      // av: 20250519 - We need to encrypt the note text because
      // at the moment rdflib cannot parse multiline text with
      // # (hash) values in them.
      String encNoteText = encryptVal(
        plainText: data.noteContent,
        encKey: data.createdDateTime,
      );

      // Create TTL body for note
      final noteTTLStr = genNoteTTLStr(
        data.createdDateTime,
        data.modifiedDateTime,
        data.noteTitle,
        encNoteText,
      );

      if (isExternal && noteUrl != '' && noteOwner != '') {
        debugPrint('noteUrl: $noteUrl');
        debugPrint('noteOwner: $noteOwner');

        // createNoteStatus = await writeExternalPod(
        await writeExternalPod(
          noteUrl,
          noteTTLStr,
          noteOwner,
        );
      } else {
        // Write note to POD
        await writePod(
          noteFileName,
          noteTTLStr,
          overwrite: overwrite,
        );
      }

      if (!context.mounted) return;

      Navigator.of(context, rootNavigator: true)
          .pop(); // Dismiss the saving note dialog

      scaffoldController.navigateToSubpage(childPage);

      if (!context.mounted) {
        throw Exception('Context not found');
      }
    } on Exception catch (e) {
      debugPrint(
        'Exception (encrypting and saving note, and navigating to return page):\n $e',
      );
    }
  }
}
