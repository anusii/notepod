/// Constants relating to the file structure for storing the notes.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Anushka Vidanage

library;

const Map fileType = {
  'acl': 'text/turtle',
  'log': 'text/plain',
  'ttl': 'text/turtle',
};

const String profCard = 'profile/card#me';

// Directory name constants.

const mainResDir = "podnotes";
const myNotesDir = 'mynotes';
const sharingDir = "sharing";
const sharedDir = "shared";
const encDir = "encryption";
const logsDir = "logs";
// const cardMe = "card#me";
const noteFileNamePrefix = 'note-';

// File name constants.

const sharedKeyFile = "shared-keys.ttl";
const encKeyFile = "enc-keys.ttl";
const pubKeyFile = "public-key.ttl";
const indKeyFile = "ind-keys.ttl";
const permLogFile = "permissions-log.ttl";

// Directory path constants.

const myNotesDirLoc = '$mainResDir/$myNotesDir';
const sharingDirLoc = '$mainResDir/$sharingDir';
const sharedDirLoc = '$mainResDir/$sharedDir';
const encDirLoc = '$mainResDir/$encDir';
const logDirLoc = '$mainResDir/$logsDir';

// Folders.

const List folders = [
  mainResDir,
  sharingDirLoc,
  sharedDirLoc,
  myNotesDirLoc,
  encDirLoc,
  logDirLoc
];

// Files.

const Map files = {
  sharingDirLoc: [
    pubKeyFile,
    '$pubKeyFile.acl',
  ],
  logDirLoc: [
    permLogFile,
    '$permLogFile.acl',
  ],
  sharedDirLoc: ['.acl'],
  encDirLoc: [encKeyFile, indKeyFile],
};
