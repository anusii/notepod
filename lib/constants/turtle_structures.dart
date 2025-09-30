/// Individual's POD content variables.
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://opensource.org/license/gpl-3-0
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

import 'package:solidpod/solidpod.dart';

// Directory name constants.

const mainResDir = 'notepod';

// const myNotesDir = 'mynotes';
const noteFileNamePrefix = 'note-';

// IRIs (Internationalized Resource Identifiers)
String notepodTerms = 'https://solidcommunity.au/' 'predicates/terms#';

String createdDateTimePred = 'createdDateTime';
String modifiedDateTimePred = 'modifiedDateTime';
String noteContentPred = 'noteContent';
String noteTitlePred = 'noteTitle';
//String encNoteContentPred = 'encNoteContent';
String mePred = ':me';
String meKey = '#me';

// Shared notes details
String sharedTime = 'sharedTime';
String noteUrl = 'noteUrl';
String noteFileName = 'noteFileName';
String noteOwner = 'noteOwner';
String permissionGranter = 'permissionGranter';
String permissionRecepient = 'permissionRecepient';
String permissionType = 'permissionType';
String permissionList = 'permissionList';

// Set up encrypted note file content
String genNoteTTLStr(
  String createdTimeStr,
  String updatedTimeStr,
  String noteTitle,
  String noteContent,
) {
  String noteTTLStr = '''@prefix : <#>.
      @prefix foaf: <$foaf>.
      @prefix terms: <$terms>.
      @prefix notepodTerms: <$notepodTerms>.
      $mePred
          a foaf:PersonalProfileDocument;
          terms:title "Note";
          notepodTerms:$createdDateTimePred "$createdTimeStr";
          notepodTerms:$modifiedDateTimePred "$updatedTimeStr";
          notepodTerms:$noteTitlePred "$noteTitle";
          notepodTerms:$noteContentPred "$noteContent".''';

  return noteTTLStr;
}

/// Selection status of notes
const String isSelectedPred = 'isSelected';
