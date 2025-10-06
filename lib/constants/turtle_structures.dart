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

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

// Directory name constants.

const mainResDir = 'notepod';

// const myNotesDir = 'mynotes';
const noteFileNamePrefix = 'note-';

// IRIs (Internationalized Resource Identifiers).
//
// 20251001 gjw Split the string to avoid lychee link check excluded.
//
// 20251001 jess The exclusions could be made as special cases in ci.yaml,
// flutter.mk.
//
// 20251001 gjw But those are tempalted files and checking for special cases
// there is awkward.

String notepodTerms = 'https://solidcommunity.au/' 'predicates/terms#';

String createdDateTimePred = 'createdDateTime';
String createdDateTimePredErr = 'createdDateERROR';
String modifiedDateTimePred = 'modifiedDateTime';
String noteContentPred = 'noteContent';
String noteTitlePred = 'noteTitle';
//String encNoteContentPred = 'encNoteContent';
String mePred = ':me';
// 20251006 jess Keep meKey as ref, even though mePred is shorthand
// String meKey = '#me';

// Shared notes details
String sharedTimePred = 'sharedTime';
String noteUrlPred = 'noteUrl';
String noteFileNamePred = 'noteFileName';
String noteOwnerPred = 'noteOwner';
String permissionGranterPred = 'permissionGranter';
String permissionRecepientPred = 'permissionRecepient';
String permissionTypePred = 'permissionType';
String permissionListPred = 'permissionList';

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

  // Generate TTL with incorrect predicate
  String noteTTLStrErr = '''@prefix : <#>.
      @prefix foaf: <$foaf>.
      @prefix terms: <$terms>.
      @prefix notepodTerms: <$notepodTerms>.
      $mePred
          a foaf:PersonalProfileDocument;
          terms:title "Note";
          notepodTerms:$createdDateTimePredErr "$createdTimeStr";
          notepodTerms:$modifiedDateTimePred "$updatedTimeStr";
          notepodTerms:$noteTitlePred "$noteTitle";
          notepodTerms:$noteContentPred "$noteContent".''';
  final String chosenTTL;
  chosenTTL = noteTTLStrErr;
  // chosenTTL = noteTTLStr;
  if (chosenTTL == noteTTLStrErr) {
    debugPrint(
      'Writing note file using incorrect predicate $createdDateTimePredErr',
    );
  } else if (chosenTTL == noteTTLStr) {
    debugPrint('Writing note file using correct predicates');
  }

  return chosenTTL;
  // return noteTTLStr;
}

/// Selection status of notes
const String isSelectedPred = 'isSelected';
