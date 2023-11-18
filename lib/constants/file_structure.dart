/// DESCRIPTION
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
/// Authors: AUTHORS

library;

const Map FILE_TYPE = {
  'acl': 'text/turtle',
  'log': 'text/plain',
  'ttl': 'text/turtle',
};

const String profCard = 'profile/card#me';

// Directory name constants
const MAIN_RES_DIR = "podnotes";
const MY_NOTES_DIR = 'mynotes';
const SHARING_DIR = "sharing";
const SHARED_DIR = "shared";
const ENC_DIR = "encryption";
const LOGS_DIR = "logs";
const CARD_ME = "card#me";

// File name constants
const SHARED_KEY_FILE = "shared-keys.ttl";
const ENC_KEY_FILE = "enc-keys.ttl";
const PUB_KEY_FILE = "public-key.ttl";
const IND_KEY_FILE = "ind-keys.ttl";
const PERM_LOG_FILE = "permissions-log.ttl";

// Directory path constants
const MY_NOTES_DIR_LOC = '$MAIN_RES_DIR/$MY_NOTES_DIR';
const SHARING_DIR_LOC = '$MAIN_RES_DIR/$SHARING_DIR';
const SHARED_DIR_LOC = '$MAIN_RES_DIR/$SHARED_DIR';
const ENC_DIR_LOC = '$MAIN_RES_DIR/$ENC_DIR';
const LOG_DIR_LOC = '$MAIN_RES_DIR/$LOGS_DIR';

// Folders
const List FOLDERS = [
  MAIN_RES_DIR,
  SHARING_DIR_LOC,
  SHARED_DIR_LOC,
  MY_NOTES_DIR_LOC,
  ENC_DIR_LOC,
  LOG_DIR_LOC
];

// Files
const Map FILES = {
  SHARING_DIR_LOC: [
    PUB_KEY_FILE,
    '$PUB_KEY_FILE.acl',
  ],
  LOG_DIR_LOC: [
    PERM_LOG_FILE,
    '$PERM_LOG_FILE.acl',
  ],
  SHARED_DIR_LOC: ['.acl'],
  ENC_DIR_LOC: [ENC_KEY_FILE, IND_KEY_FILE],
};
