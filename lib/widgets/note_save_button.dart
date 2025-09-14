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
import 'package:notepod/notes/edit_note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/shared_notes/view_shared_note.dart';
import 'package:notepod/utils/encryption.dart';
import 'package:notepod/widgets/err_dialogs.dart';
import 'package:notepod/widgets/loading_animation.dart';

/// A stylised save button widget for notes.

class NoteSaveButton extends StatelessWidget {
  final TextEditingController textController;
  final GlobalKey<FormBuilderState> formKey;
  final Map? prevNoteData;
  final bool shared;
  final Map notesMap;

  const NoteSaveButton({
    super.key,
    required this.textController,
    required this.formKey,
    this.prevNoteData,
    required this.shared,
    this.notesMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(
        Icons.save,
        color: Colors.white,
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
      style: ElevatedButton.styleFrom(
        foregroundColor: darkBlue,
        backgroundColor: lightBlue, // foreground
        padding: const EdgeInsets.symmetric(
          // Slightly larger edgeinset than back button to
          // emphasise save button
          horizontal: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      label: const Text(
        'SAVE',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

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

    final SolidFunctionCallStatus createNoteStatus;
    Map formData = formKey.currentState?.value as Map;
    String noteText = textController.text;
    Map noteNewData = {};

    // Previous shared note info only used when saveNote() on edit shared note
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
        showErrDialog(context, 'You have no new changes!');
      } else {
        // Loading animation
        showAnimationDialog(
          context,
          17,
          'Saving the note!',
          false,
        );

        // Update existing note
        String createdDateTimeStr = prevNoteData[createdDateTimePred];

        // Format new note data structure
        noteNewData = await prepNewNoteData(
          createdDateTimeStr,
          modifiedDateTimeStr,
          noteTitle,
          noteText,
        );

        if (shared) {
          // Shared edited note
          // New full note data
          Map newFullNoteData = {
            'sharedNoteInfo': prevSharedNoteInfo,
            'sharedNoteContent': noteNewData,
          };
          // Encrypt note, create TTL, update file in POD
          if (context.mounted) {
            createNoteStatus = await saveNoteToPod(
              context,
              noteNewData,
              ViewSharedNote(
                fullNoteData: newFullNoteData,
              ),
              shared,
              prevSharedNoteInfo,
            );

            // Navigate to return page
            postSaveNav(
              // context.mounted checked already
              // ignore: use_build_context_synchronously
              context,
              createNoteStatus,
              ViewSharedNote(
                fullNoteData: newFullNoteData,
              ),
            );
          }
        } else {
          // Non-shared edited note
          // Encrypt note, create TTL, update file in POD
          if (context.mounted) {
            createNoteStatus = await saveNoteToPod(
              context,
              noteNewData,
              EditNote(
                noteData: noteNewData,
                notesMap: notesMap,
              ),
              shared,
            );

            // Navigate to return page
            postSaveNav(
              // context.mounted checked already
              // ignore: use_build_context_synchronously
              context,
              createNoteStatus,
              ViewNote(noteData: noteNewData, notesMap: notesMap),
            );
          }
        }
      }
    } else {
      // Newly created note (not editing previous note)

      // Check note content is not empty
      if (noteText.trim() != '') {
        // Loading animation
        showAnimationDialog(
          context,
          17,
          'Saving the note!',
          false,
        );

        // Format new note data structure
        // As new note, use modoifiedDateTimeStr for creation datetimestamp
        noteNewData = await prepNewNoteData(
          modifiedDateTimeStr,
          modifiedDateTimeStr,
          noteTitle,
          noteText,
        );

        // Encrypt note, create TTL and write to file in POD
        if (context.mounted) {
          createNoteStatus = await saveNoteToPod(
            context,
            noteNewData,
            ListNotesScreen(),
          );

          // Navigate to return page
          postSaveNav(
            // context.mounted checked already
            // ignore: use_build_context_synchronously
            context,
            createNoteStatus,
            ListNotesScreen(),
          );
        }
      } else {
        // Nn note content message
        Navigator.pop(context);
        showErrDialog(context, 'Please enter some note content.');
      }
    }
  } else {
    showErrDialog(
      context,
      'Note name validation failed! Try using a different name.',
    );
  }
}

Future<Map> prepNewNoteData(
  String createdDateTimeStr,
  String modifiedDateTimeStr,
  String noteTitle,
  String noteText,
) async {
  Map noteNewData = {};

  noteNewData[noteTitlePred] = noteTitle;
  noteNewData[createdDateTimePred] = createdDateTimeStr;
  noteNewData[modifiedDateTimePred] = modifiedDateTimeStr;
  noteNewData[noteContentPred] = noteText;

  return noteNewData;
}

Future<SolidFunctionCallStatus> saveNoteToPod(
  BuildContext context,
  Map noteNewData,
  Widget returnPage, [
  bool shared = false,
  Map prevSharedNoteInfo = const {},
]) async {
  // Encrypt note text using created time as the key
  // av: 20250519 - We need to encrypt the note text because
  // at the moment rdflib cannot parse multiline text with
  // # (hash) values in them.
  String encNoteText = encryptVal(
    noteNewData[noteContentPred],
    noteNewData[createdDateTimePred],
  );

  // Create note file name
  // String noteFileName =
  //     '$noteFileNamePrefix$noteTitle-$dateTimeStr.ttl';
  String noteFileName =
      '$noteFileNamePrefix${noteNewData[createdDateTimePred]}.ttl';

  // Create TTL body for note
  final noteTTLStr = genNoteTTLStr(
    noteNewData[createdDateTimePred],
    noteNewData[modifiedDateTimePred],
    noteNewData[noteTitlePred],
    encNoteText,
  );

  if (shared) {
    // Get note url
    String noteFileUrl = prevSharedNoteInfo[noteUrl];

    // Get note owner webId
    String noteOwnerWebId = prevSharedNoteInfo[noteOwner];

    return await writeExternalPod(
      noteFileUrl,
      noteTTLStr,
      noteOwnerWebId,
      context,
      returnPage,
    );
  } else {
// Write note to POD
    return await writePod(
      noteFileName,
      noteTTLStr,
      context,
      returnPage,
      //encrypted: false, // save in plain text for now
    );
  }
}

Future<void> postSaveNav(
  BuildContext context,
  SolidFunctionCallStatus createNoteStatus,
  Widget returnPage,
) async {
  if (createNoteStatus == SolidFunctionCallStatus.success) {
    //Navigator.pop(context);

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
    Navigator.pop(context);
    showErrDialog(
      context,
      'Failed to store the note file in your POD. Try again!',
    );
  }
}
