// Flutter imports:
import 'package:flutter/material.dart';

const kDefaultPadding = 20.0;
const double normalLoadingScreenHeight = 200.0;

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

// Const text labels
const LOGIN_TIMEOUT_TITLE = 'Login Timeout!';
const LOGIN_TIMEOUT_ERR =
    'Your login session has expired! Please login again to continue.';

const INITIAL_STRUC_WELCOME =
    '''Welcome to PODNotes initial structure setup wizard!''';

const INITIAL_STRUC_TITLE = '''Structure setup wizard!''';

const INITIAL_STRUC_MSG =
    'You are being re-directed to this page because you have either created a completely new POD and you will need to setup the initial resource structure to start using the app OR we have detected some missing files and/or folders in your POD that will prevent you from using some functionalities of the app, and therefore need to be re-created.';

const REQUIRE_PWD_MSG =
    'We would also need a password (a master key) for the encryption of notes. For this password you can use the same password you use for login to your POD (not recommended) or a completely different password (highly recommended). Please enter your password below.';

const PUBLIC_KEY_MSG =
    'We will also create a random public/private key pair for secure data sharing with other PODs.';

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
  '$SHARING_DIR_LOC': [
    PUB_KEY_FILE,
    '$PUB_KEY_FILE.acl',
  ],
  '$LOG_DIR_LOC': [
    PERM_LOG_FILE,
    '$PERM_LOG_FILE.acl',
  ],
  '$SHARED_DIR_LOC': ['.acl'],
  '$ENC_DIR_LOC': [ENC_KEY_FILE, IND_KEY_FILE],
};
