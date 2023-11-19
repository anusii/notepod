const Map fileType = {
  'acl': 'text/turtle',
  'log': 'text/plain',
  'ttl': 'text/turtle',
};

const String profCard = 'profile/card#me';

// Directory name constants
const mainResDir = "podnotes";
const myNotesDir = 'mynotes';
const sharingDir = "sharing";
const sharedDir = "shared";
const encDir = "encryption";
const logsDir = "logs";
const cardMe = "card#me";

// File name constants
const sharedKeyFile = "shared-keys.ttl";
const encKeyFile = "enc-keys.ttl";
const pubKeyFile = "public-key.ttl";
const indKeyFile = "ind-keys.ttl";
const permLogFile = "permissions-log.ttl";

// Directory path constants
const myNotesDirLoc = '$mainResDir/$myNotesDir';
const sharingDirLoc = '$mainResDir/$sharingDir';
const sharedDirLoc = '$mainResDir/$sharedDir';
const encDirLoc = '$mainResDir/$encDir';
const logDirLoc = '$mainResDir/$logsDir';

// Folders
const List folders = [
  mainResDir,
  sharingDirLoc,
  sharedDirLoc,
  myNotesDirLoc,
  encDirLoc,
  logDirLoc
];

// Files
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
