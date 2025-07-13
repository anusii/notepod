import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:solidpod/solidpod.dart';
import 'package:notepod/home.dart';
import 'package:intl/intl.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/notes/edit_note.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/shared_notes/view_shared_note.dart';
import 'package:notepod/utils/encryption.dart';
import 'package:notepod/widgets/err_dialogs.dart';
import 'package:notepod/widgets/loading_animation.dart';
import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';

Future<void> saveNote(BuildContext context,
    TextEditingController _textController, GlobalKey<FormBuilderState> formKey,
    [Map? prevNoteData, bool shared = false]) async {
  if (formKey.currentState?.saveAndValidate() ?? false) {
    // Compares to prevNoteData if previous note data provided
    // Adds sharing metadata if shared==true

    final createNoteStatus;
    Map formData = formKey.currentState?.value as Map;
    String noteText = _textController.text;
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
            createdDateTimeStr, modifiedDateTimeStr, noteTitle, noteText);

        if (shared) {
          // Shared edited note
          // New full note data
          Map newFullNoteData = {
            'sharedNoteInfo': prevSharedNoteInfo,
            'sharedNoteContent': noteNewData
          };
          // Encrypt note, create TTL, update file in POD
          createNoteStatus = await saveNoteToPod(
              context,
              noteNewData,
              ViewSharedNote(
                fullNoteData: newFullNoteData,
              ),
              shared,
              prevSharedNoteInfo);

          // Navigate to return page
          postSaveNav(
              context,
              createNoteStatus,
              ViewSharedNote(
                fullNoteData: newFullNoteData,
              ));
        } else {
          // Non-shared edited note
          // Encrypt note, create TTL, update file in POD
          createNoteStatus = await saveNoteToPod(
              context,
              noteNewData,
              EditNote(
                noteData: noteNewData,
              ),
              shared);

          // Navigate to return page
          postSaveNav(
              context, createNoteStatus, ViewNote(noteData: noteNewData));
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
            modifiedDateTimeStr, modifiedDateTimeStr, noteTitle, noteText);

        // Encrypt note, create TTL and write to file in POD
        createNoteStatus = await saveNoteToPod(context, noteNewData, Home());

        // Navigate to return page
        postSaveNav(context, createNoteStatus, Home());
      } else {
        Navigator.pop(context);
        showErrDialog(context, 'Please enter some note content.');
      }
    }
  } else {
    showErrDialog(
        context, 'Note name validation failed! Try using a different name.');
  }
}

Future<Map> prepNewNoteData(String createdDateTimeStr,
    String modifiedDateTimeStr, String noteTitle, String noteText) async {
  Map _noteNewData = {};

  _noteNewData[noteTitlePred] = noteTitle;
  _noteNewData[createdDateTimePred] = createdDateTimeStr;
  _noteNewData[modifiedDateTimePred] = modifiedDateTimeStr;
  _noteNewData[noteContentPred] = noteText;

  return _noteNewData;
}

Future<SolidFunctionCallStatus> saveNoteToPod(
    BuildContext context, Map noteNewData, Widget returnPage,
    [bool shared = false, Map prevSharedNoteInfo = const {}]) async {
  // Encrypt note text using created time as the key
  // av: 20250519 - We need to encrypt the note text because
  // at the moment rdflib cannot parse multiline text with
  // # (hash) values in them.
  String encNoteText = encryptVal(
      noteNewData[noteContentPred], noteNewData[createdDateTimePred]);

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
      encNoteText);

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

Future<void> postSaveNav(BuildContext context,
    SolidFunctionCallStatus createNoteStatus, Widget returnPage) async {
  if (createNoteStatus == SolidFunctionCallStatus.success) {
    //Navigator.pop(context);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => AppScreen(
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
        context, 'Failed to store the note file in your POD. Try again!');
  }
}
