/// The edit note page.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2025-07-16 08:32:47 +1100 Jess Moore>
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
/// Authors: Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:solidpod/solidpod.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/home.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/shared_notes/view_shared_note.dart';
import 'package:notepod/utils/encryption.dart';
import 'package:notepod/widgets/err_dialogs.dart';
import 'package:notepod/widgets/loading_animation.dart';

/// A stylised save button widget which on click saves the note content
/// Pod. External notes are written to the note owner's Pod. Notes created
/// by the user are written to the user's Pod.
///
/// Examples
/// - `NoteSaveButton(textController: _textController!, formKey: formKey, shared: shared, notesMap: notesMap)` save the metadata and content of a new note to user's Pod.
/// - `NoteSaveButton(textController: _textController!, formKey: formKey, prevNoteData: prevNoteData, shared: shared, notesMap: notesMap)` save the updated metadata and content of an existing note to the owner's Pod (whether that be the user or an external owner).
///
/// - [textController] - Text controller of the note text content editor.
/// - [formKey] - Key of the form to edit the note metadata
/// - [notesMap] - Map of current data of the note to write to Pod
/// - [prevNoteData] - Optional map of previous data of an existing note. Required for existing notes
/// - [shared] - Optional boolean denoting whether external note (default: false)

class NoteSaveButton extends StatelessWidget {
  final TextEditingController textController;
  final GlobalKey<FormBuilderState> formKey;
  final Map notesMap;
  final Map? prevNoteData;
  final bool shared;

  const NoteSaveButton({
    super.key,
    required this.textController,
    required this.formKey,
    required this.notesMap,
    this.prevNoteData,
    this.shared = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Uses Theme elevatedButtonTheme for all properties
      // except background color and padding
      icon: const Icon(
        Icons.save,
      ),
      onPressed: () async {
        // Save note and redirect to view note page
        await saveNote(
          context,
          textController,
          formKey,
          prevNoteData,
          shared,
          notesMap,
        );
      },
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor:
                WidgetStateProperty.all<Color>(ButtonBackgroundColor.save),
            // Larger edgeinsets to emphasise save button
            padding: WidgetStateProperty.all<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
      label: const Text(
        'SAVE',
      ),
    );
  }
}

/// Function that starts a waiting indicator, calls steps to save note,
/// and then navigates to the appropriate return page.
///
/// Examples:
/// - `saveNote(ontext, textController, formKey, prevNoteData, shared, notesMap)`
///
/// - [context] - The build context
/// - [textController] - Text controller of the note text content editor.
/// - [formKey] - Key of the form to edit note metadata
/// - [prevNoteData] - Optional map of previous data of an existing note. Required for existing notes (default: null)
/// - [shared] - Optional boolean denoting whether external note (default: false)
/// - [notesMap] - Map of current data of note to write to Pod
Future<void> saveNote(
  BuildContext context,
  TextEditingController textController,
  GlobalKey<FormBuilderState> formKey, [
  Map? prevNoteData,
  bool shared = false,
  Map notesMap = const {},
]) async {
  if (formKey.currentState?.saveAndValidate() ?? false) {
    // Compares to prevNoteData if previous note data provided
    // Adds sharing metadata if shared==true

    // final SolidFunctionCallStatus createNoteStatus;
    Map formData = formKey.currentState?.value as Map;
    String noteText = textController.text;
    Map noteNewData = {};

    // Previous external note info, required for saving an external note
    Map prevSharedNoteInfo = {};

    // Note title need to be spaceless as we are using that name
    // to create a .acl file. And the acl file url cannot have spaces
    String noteTitle = formData[noteTitlePred].replaceAll('\n', '');

    // Get current datetimestamp for mod time and/or creation time
    String modifiedDateTimeStr =
        DateFormat('yyyyMMddTHHmmss').format(DateTime.now()).toString();

    if (shared) {
      Map prevNoteFullData = prevNoteData!;
      prevNoteData = prevNoteFullData['sharedNoteContent'];
      prevSharedNoteInfo = prevNoteFullData['sharedNoteInfo'];
    }

    if (prevNoteData != null) {
      if (noteTitle == prevNoteData[noteTitlePred] &&
          noteText == prevNoteData[noteContentPred]) {
        showErrDialog(context, ErrMsg.noChanges);
      } else {
        try {
          // Loading animation
          showAnimationDialog(
            context,
            Msg.savingNote,
            false,
          );

          // Format new note data structure
          noteNewData = makeNewNoteData(
            prevNoteData[createdDateTimePred], // prev note creation date
            modifiedDateTimeStr,
            noteTitle,
            noteText,
          );
        } on Exception catch (e) {
          debugPrint('Exception (formatting update to existing note):\n $e');
        }

        if (shared) {
          // Shared edited note
          // New full note data
          try {
            Map newFullNoteData = {
              'sharedNoteInfo': prevSharedNoteInfo,
              'sharedNoteContent': noteNewData,
            };

            if (!context.mounted) return;

            // External note
            // Encrypt note, create TTL, update file in POD
            await saveNoteToPod(
              context,
              noteNewData,
              ViewSharedNote(
                fullNoteData: newFullNoteData,
              ),
              shared,
              prevSharedNoteInfo,
            );
          } on Exception catch (e) {
            debugPrint('Exception (saving existing external note):\n $e');
          }
        } else {
          // Edited my note
          // Encrypt note, create TTL, update file in POD
          try {
            if (!context.mounted) return;

            await saveNoteToPod(
              context,
              noteNewData,
              ViewNote(
                noteData: noteNewData,
                notesMap: notesMap,
              ),
              // shared,
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
          showAnimationDialog(
            context,
            Msg.savingNote,
            false,
          );

          // Format new note data structure
          // As new note, modoifiedDateTimeStr = creation datetimestamp
          noteNewData = makeNewNoteData(
            modifiedDateTimeStr,
            modifiedDateTimeStr,
            noteTitle,
            noteText,
          );

          // Encrypt note, create TTL and write to file in POD
          if (!context.mounted) return;

          // createNoteStatus = await saveNoteToPod(
          await saveNoteToPod(
            context,
            noteNewData,
            ListNotesScreen(),
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

/// Format the note data in json key-value structure used for notes, where keys are [noteTitlePred], [createdDateTimePred], [modifiedDateTimePred], and [noteContentPred].
///
/// - [createdDateTimeStr] - date time stamp of file creation time
/// - [modifiedDateTimeStr] - data time stamp of last file modification time
/// - [noteTitle] - note title
/// - [noteText] - text of note content
Map<String, dynamic> makeNewNoteData(
  String createdDateTimeStr,
  String modifiedDateTimeStr,
  String noteTitle,
  String noteText,
) {
  Map<String, dynamic> noteNewData = {};

  noteNewData[noteTitlePred] = noteTitle;
  noteNewData[createdDateTimePred] = createdDateTimeStr;
  noteNewData[modifiedDateTimePred] = modifiedDateTimeStr;
  noteNewData[noteContentPred] = noteText;

  return noteNewData;
}

/// Write note to Pod and navigate to return page or display error dialog
/// if write to Pod failed to return a successful SolidCallFunctionStatus.
///
/// Examples:
/// - `await saveNoteToPod(context, noteNewData, ListNotesScreen())` writes metadata and encrypted content of a note owned by user to a turtle file (with filename based on the file creation date) in the user's Pod. On successful completion returns to my notes list.
/// - `await saveNoteToPod(context, noteNewData, ViewSharedNote(fullNoteData: newFullNoteData), shared, prevSharedNoteInfo)` writes metadata and encrypted content of an external note to the owner's Pod file. On successful completion returns to view that external note.
///
/// - [context] - The build context
/// - [noteNewData] - The map of note data to be encrypted and written to Pod
/// - [returnPage] - The destination widget to navigate to after note is saved
/// - [shared] - Optional boolean defining whether updating an existing external note (default: false)
/// - [prevSharedNoteInfo] - Optional map of existing note information. Required for updating existing external notes (default: {})
Future<void> saveNoteToPod(
  BuildContext context,
  Map noteNewData,
  Widget returnPage, [
  bool shared = false,
  Map prevSharedNoteInfo = const {},
]) async {
  /// The returned status of the Solid function call to write
  /// data to Pod
  final SolidFunctionCallStatus createNoteStatus;

  try {
    // Encrypt note text using created time as the key
    // av: 20250519 - We need to encrypt the note text because
    // at the moment rdflib cannot parse multiline text with
    // # (hash) values in them.
    String encNoteText = encryptVal(
      noteNewData[noteContentPred],
      noteNewData[createdDateTimePred],
    );

    // Create TTL body for note
    final noteTTLStr = genNoteTTLStr(
      noteNewData[createdDateTimePred],
      noteNewData[modifiedDateTimePred],
      noteNewData[noteTitlePred],
      encNoteText,
    );

    if (shared) {
      // Url of existing external note
      String noteFileUrl = prevSharedNoteInfo[noteUrl];

      // WebId of note owner of existing external note
      String noteOwnerWebId = prevSharedNoteInfo[noteOwner];

      createNoteStatus = await writeExternalPod(
        noteFileUrl,
        noteTTLStr,
        noteOwnerWebId,
        context,
        returnPage,
      );
    } else {
      // Create note file name
      // String noteFileName =
      //     '$noteFileNamePrefix$noteTitle-$dateTimeStr.ttl';
      String noteFileName =
          '$noteFileNamePrefix${noteNewData[createdDateTimePred]}.ttl';

      // Write note to POD
      createNoteStatus = await writePod(
        noteFileName,
        noteTTLStr,
        context,
        returnPage,
        //encrypted: false, // save in plain text for now
      );
    }

    if (createNoteStatus == SolidFunctionCallStatus.success) {
      if (!context.mounted) return;

      Navigator.of(context, rootNavigator: true)
          .pop(); // Dismiss the saving note dialog

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AppHomePage(
            title: topBarTitle,
            childPage: returnPage,
          ),
        ),
        (Route<dynamic> route) =>
            false, // This predicate ensures all previous routes are removed
      );
    } else {
      // Show SolidFunctionCallStatus after writePod() if not success
      debugPrint(
        'SolidFunctionCallStatus: ${createNoteStatus.toString()}',
      );

      if (!context.mounted) return;

      Navigator.of(context, rootNavigator: true)
          .pop(); // Dismiss the saving note dialog

      showErrDialog(
        context,
        ErrMsg.saveFailed,
      );
    }

    if (!context.mounted) {
      throw Exception('Context not found');
    }
  } on Exception catch (e) {
    debugPrint(
      'Exception (encrypting and saving note, and navigating to return page):\n $e',
    );
  }
}
