/// App-wide constants.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Wednesday 2023-11-01 08:26:39 +1100 Graham Williams>
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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

const String applicationRepo = 'https://github.com/anusii/notepod';
const String siiUrl = 'https://sii.anu.edu.au';
const String topBarTitle = 'NotePod - Private and Shareable Notes';

const String authors =
    'Authors: Anushka Vidanage, Graham Williams, Jess Moore.';

//const kDefaultPadding = 20.0;
const double normalLoadingScreenHeight = 200.0;
//const double buttonBorderRadius = 5;
//const double standardSpace = 20.0;
const double badListItemHeight = 68.0;

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
//double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

const nonReadableNoteMsg =
    'You do not have read access to this note and therefore cannot view that. However, you can delete it or share it with others.';

//const noNotesMsg = 'You do not have any notes yet!';

const noSharedNotesMsg = 'You do not have any notes shared with you yet!';

// SizedBox standardHeight() {
//   return const SizedBox(
//     height: standardSpace / 2,
//   );
// }

const double desktopWidthThreshold = 960;

// Text style of page titles
const titleStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.bold,
);

// Text style for metadata
const metadataTextStyle = TextStyle(
  fontSize: 12,
);

// Titles for nav widgets to pages
const String myNotesTitle = 'My Notes';
const String sharedNotesTitle = 'Shared Notes';

/// Note list messages
class NoteListMsg {
  /// Message displayed when corrupt files found
  static const String badFilesFound = 'Corrupt note files present';

  /// Message displayed when no notes found in user's Pod
  static const String noNotes = 'No notes yet!';

  /// Advises user to write their first note
  static const String writeFirstNote = 'Write your first note';
}

/// Note action messages
class Msg {
  /// Note saving message
  static const String savingNote = 'Saving the note!';

  /// Note deleting message
  static const String deletingNote = 'Deleting the note!';

  /// Confirm delete note message
  static const String confirmDelete =
      'Are you sure you want to delete this note?';

  static const String confirmDeleteMultiple =
      'Are you sure you want to delete these notes?';

  // Please confirm message
  static const String plsConfirm = 'Please Confirm';
}

/// Error messages for errors occuring on note actions
class ErrMsg {
  /// No changes to note error.
  static const String noChanges = 'You have no new changes!';

  /// No note content.
  static const String noContent = 'Please enter some note content.';

  /// Invalid note name.
  static const String invalidName =
      'Note name validation failed! Try using a different name.';

  /// Error message when fails to save note file to POD
  static const String saveFailed =
      'Failed to store the note file in your POD. Try again!';

  /// Unsaved changes found
  static const String unsavedChanges = 'Unsaved changed found!';
}

class NoteIconSize {
  static const double width = 50;
  static const double height = 50;
  static const double twoIconWidth = (width * 2) + gap;
  static const double gap = 15;
}

// EdgeInsets for metadata block on view notes
const EdgeInsets metadataPadding = EdgeInsets.fromLTRB(15, 5, 10, 0);

/// Button shape decoration for list pages
ShapeDecoration buttonShapeList =
    const ShapeDecoration(color: Colors.grey, shape: CircleBorder());
