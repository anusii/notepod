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
/// Authors: Zheyuan Xu
library;

import 'package:jwt_decoder/jwt_decoder.dart';
//import 'package:indipod/home/profile_data.dart';

// IRIs (Internationalized Resource Identifiers)
String podnotesTerms = 'https://solidcommunity.au/predicates/terms#';
String podnotesFile = 'https://solidcommunity.au/predicates/file#';
String podnotesLogId = 'https://solidcommunity.au/predicates/logid#';
String solid = 'http://www.w3.org/ns/solid/terms#';
String foaf = 'http://xmlns.com/foaf/0.1/';
String terms = 'http://purl.org/dc/terms/';
String acl = 'http://www.w3.org/ns/auth/acl#';

// String encKeyPred = 'https://solidcommunity.au/predicates/terms#encKey';
// String sessionKeyPred = 'https://solidcommunity.au/predicates/terms#sessionKey';
// String prvKeyPred = 'https://solidcommunity.au/predicates/terms#prvKey';
// String pubKeyPred = 'https://solidcommunity.au/predicates/terms#pubKey';
// String filePred = 'https://solidcommunity.au/predicates/file#';
// String logIdPred = 'https://solidcommunity.au/predicates/logid#';
// String noteDateTimePred =
//     'https://solidcommunity.au/predicates/terms#noteDateTime';

// String noteContentPred =
//     'https://solidcommunity.au/predicates/terms#noteContent';
// String encNoteContentPred =
//     'https://solidcommunity.au/predicates/terms#encNoteContent';
// String encNoteIvPred = 'https://solidcommunity.au/predicates/terms#encNoteIv';
// String ivzPred = 'https://solidcommunity.au/predicates/terms#iv';
// String dataPred = 'https://solidcommunity.au/predicates/data#';

// Predicate labels
String titlePred = 'title';
String pathPred = 'path';
String encKeyPred = 'encKey';
String sessionKeyPred = 'sessionKey';
String prvKeyPred = 'prvKey';
String pubKeyPred = 'pubKey';
String noteDateTimePred = 'noteDateTime';
String encNoteContentPred = 'encNoteContent';
String noteTitlePred = 'noteTitle';
String ivPred = 'iv';

// Set up encryption key file content
String genEncKeyBody(
    String encMasterKey, String prvKey, String prvKeyIvz, String resUrl) {
  // Create a ttl file body
  String keyFileBody =
      '<$resUrl> <$terms$titlePred> "Encryption keys";\n    <$podnotesTerms$ivPred> "$prvKeyIvz";\n    <$podnotesTerms$encKeyPred> "$encMasterKey";\n    <$podnotesTerms$prvKeyPred> "$prvKey".';

  return keyFileBody;
}

// Set up public file acl content
String genPubFileAclBody(String fileName) {
  // Create file body
  String resName = fileName.replaceAll('.acl', '');
  String pubFileBody =
      '@prefix : <#>.\n@prefix acl: <$acl>.\n@prefix foaf: <$foaf>.\n@prefix c: <card#>.\n\n:owner\n    a acl:Authorization;\n    acl:accessTo <$resName>;\n    acl:agent c:me;\n    acl:mode acl:Control, acl:Read, acl:Write.\n\n:public\n    a acl:Authorization;\n    acl:accessTo <$resName>;\n    acl:agentClass foaf:Agent;\n    acl:mode acl:Read, acl:Write.';

  return pubFileBody;
}

// Set up private file acl content
String genPrvFileAclBody(String fileName, String webId) {
  String webIdStr = webId.replaceAll('me', '');
  String resName = fileName.replaceAll('.acl', '');
  String prvFileBody =
      '@prefix : <#>.\n@prefix acl: <$acl>.\n@prefix p: <$webIdStr>.\n\n:ControlReadWrite\n    a acl:Authorization;\n    acl:accessTo <$resName>;\n    acl:agent p:me;\n    acl:mode acl:Control, acl:Read, acl:Write.';

  return prvFileBody;
}

// Set up public directory acl content
String genPubDirAclBody() {
  // Create file body
  String pubFileBody =
      '@prefix : <#>.\n@prefix acl: <$acl>.\n@prefix foaf: <$foaf>.\n@prefix shrd: <./>.\n@prefix c: </profile/card#>.\n\n:owner\n    a acl:Authorization;\n    acl:accessTo shrd:;\n    acl:agent c:me;\n    acl:mode acl:Control, acl:Read, acl:Write.\n\n:public\n    a acl:Authorization;\n    acl:accessTo shrd:;\n    acl:default shrd:;\n    acl:agentClass foaf:Agent;\n    acl:mode acl:Read, acl:Write.';

  return pubFileBody;
}

// Set up individual key file content
String genIndKeyFileBody() {
  String keyFileBody =
      '@prefix : <#>.\n@prefix foaf: <$foaf>.\n@prefix terms: <$terms>.\n@prefix file: <$podnotesFile>.\n@prefix podnotesTerms: <$podnotesTerms>.\n:me\n    a foaf:PersonalProfileDocument;\n    terms:title "Individual Encryption Keys".';

  return keyFileBody;
}

// Set up public key file content
String genPubKeyFileBody(String resUrl, String pubKeyStr) {
  String keyFileBody =
      '<$resUrl> <$terms$titlePred> "Public key";\n    <$podnotesTerms$pubKeyPred> "$pubKeyStr";';

  return keyFileBody;
}

// Set up public profile file content
String genProfFileBody(Map profData, Map authData) {
  Map<String, dynamic> decodedToken =
      JwtDecoder.decode(authData['accessToken']);
  String issuerUri = decodedToken['iss'];

  var name = profData['name'];
  var gender = profData['gender'];

  String fileBody =
      '@prefix : <#>.\n@prefix foaf: <$foaf>.\n@prefix solid: <$solid>.\n@prefix vcard: <http://www.w3.org/2006/vcard/ns#>.\n@prefix pro: <./>.\n\npro:card a foaf:PersonalProfileDocument; foaf:maker :me; foaf:primaryTopic :me.\n\n:me\n    solid:oidcIssuer <$issuerUri>;\n    a foaf:Person;\n    vcard:fn "$name";\n    vcard:Gender "$gender";\n    foaf:name "$name".';

  return fileBody;
}

// String updateProfile(String editField, String editContent, Map authData) {
//   profData[editField] = editContent;
//   return genProfFileBody(profData, authData);
// }

// Set up log file content
String genLogFileBody() {
  String logFileBody =
      '@prefix : <#>.\n@prefix foaf: <$foaf>.\n@prefix terms: <$terms>.\n@prefix logid: <$podnotesLogId>.\n@prefix podnotesTerms: <$podnotesTerms>.\n:me\n    a foaf:PersonalProfileDocument;\n    terms:title "Permissions Log".';

  return logFileBody;
}

// Set up log acl file content
String genLogAclBody(String webId, String permFileName) {
  String webIdStr = webId.replaceAll('me', '');
  String logAclFileBody =
      '@prefix : <#>.\n@prefix acl: <$acl>.\n@prefix foaf: <$foaf>.\n@prefix c: <$webIdStr>.\n\n:owner\n    a acl:Authorization;\n    acl:accessTo <$permFileName>;\n    acl:agent c:me;\n    acl:mode acl:Control, acl:Read, acl:Write.\n\n:public\n    a acl:Authorization;\n    acl:accessTo <$permFileName>;\n    acl:agentClass foaf:Agent;\n    acl:mode acl:Append.';

  return logAclFileBody;
}

// Set up encrypted note file content
String genEncryptedNoteFileBody(String dateTimeStr, String noteTitle,
    String encNoteContent, String encNoteIv) {
  String encNoteFileBody =
      '@prefix : <#>.\n@prefix foaf: <$foaf>.\n@prefix terms: <$terms>.\n@prefix podnotesTerms: <$podnotesTerms>.\n:me\n    a foaf:PersonalProfileDocument;\n    terms:title "Encrypted Note";\n    podnotesTerms:$noteDateTimePred "$dateTimeStr";\n    podnotesTerms:$ivPred "$encNoteIv";\n    podnotesTerms:$noteTitlePred "$noteTitle";\n    podnotesTerms:$encNoteContentPred "$encNoteContent".';

  return encNoteFileBody;
}
