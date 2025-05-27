/// Individual's POD content variables.
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://www.gnu.org/licenses/gpl-3.0.en.html
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
/// Authors: Anushka Vidanage
library;

// Profile card constant
const String profCard = 'profile/card#me';

// Directory name constants.
const mainResDir = 'notepod';
const dataDir = 'data';
const myNotesDir = 'mynotes';
const noteFileNamePrefix = 'note-';

// IRIs (Internationalized Resource Identifiers)
String notepodTerms = 'https://solidcommunity.au/predicates/terms#';
String foaf = 'http://xmlns.com/foaf/0.1/';
String terms = 'http://purl.org/dc/terms/';

String createdDateTimePred = 'createdDateTime';
String modifiedDateTimePred = 'modifiedDateTime';
String noteContentPred = 'noteContent';
String noteTitlePred = 'noteTitle';
String encNoteContentPred = 'encNoteContent';
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
  String noteTTLStr =
      '@prefix : <#>.\n@prefix foaf: <$foaf>.\n@prefix terms: <$terms>.\n@prefix notepodTerms: <$notepodTerms>.\n$mePred\n    a foaf:PersonalProfileDocument;\n    terms:title "Note";\n    notepodTerms:$createdDateTimePred "$createdTimeStr";\n    notepodTerms:$modifiedDateTimePred "$updatedTimeStr";\n    notepodTerms:$noteTitlePred "$noteTitle";\n    notepodTerms:$noteContentPred "$noteContent".';

  return noteTTLStr;
}
