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

import 'package:jwt_decoder/jwt_decoder.dart';
//import 'package:indipod/home/profile_data.dart';

// Predicates used in the app
String encKeyPred = 'https://solidcommunity.au/predicates/terms#encKey';
String sessionKeyPred = 'https://solidcommunity.au/predicates/terms#sessionKey';
String prvKeyPred = 'https://solidcommunity.au/predicates/terms#prvKey';
String pubKeyPred = 'https://solidcommunity.au/predicates/terms#pubKey';
String filePred = 'https://solidcommunity.au/predicates/file#';
String logIdPred = 'https://solidcommunity.au/predicates/logid#';
String ivzPred = 'https://solidcommunity.au/predicates/terms#iv';
String dataPred = 'https://solidcommunity.au/predicates/data#';
String genderPred = 'https://solidcommunity.au/predicates/personal#Gender';

// Set up encryption key file content
String genEncKeyBody(
    String encMasterKey, String prvKey, String prvKeyIvz, String resUrl) {
  // Create a ttl file body
  String keyFileBody =
      '<$resUrl> <http://purl.org/dc/terms/title> "Encryption keys";\n    <$ivzPred> "$prvKeyIvz";\n    <$encKeyPred> "$encMasterKey";\n    <$prvKeyPred> "$prvKey".';

  return keyFileBody;
}

// Set up public file acl content
String genPubFileAclBody(String fileName) {
  // Create file body
  String resName = fileName.replaceAll('.acl', '');
  String pubFileBody =
      '@prefix : <#>.\n@prefix acl: <http://www.w3.org/ns/auth/acl#>.\n@prefix foaf: <http://xmlns.com/foaf/0.1/>.\n@prefix c: <card#>.\n\n:owner\n    a acl:Authorization;\n    acl:accessTo <$resName>;\n    acl:agent c:me;\n    acl:mode acl:Control, acl:Read, acl:Write.\n\n:public\n    a acl:Authorization;\n    acl:accessTo <$resName>;\n    acl:agentClass foaf:Agent;\n    acl:mode acl:Read, acl:Write.';

  return pubFileBody;
}

// Set up private file acl content
String genPrvFileAclBody(String fileName, String webId) {
  String webIdStr = webId.replaceAll('me', '');
  String resName = fileName.replaceAll('.acl', '');
  String prvFileBody =
      '@prefix : <#>.\n@prefix acl: <http://www.w3.org/ns/auth/acl#>.\n@prefix p: <$webIdStr>.\n\n:ControlReadWrite\n    a acl:Authorization;\n    acl:accessTo <$resName>;\n    acl:agent p:me;\n    acl:mode acl:Control, acl:Read, acl:Write.';

  return prvFileBody;
}

// Set up public directory acl content
String genPubDirAclBody() {
  // Create file body
  String pubFileBody =
      '@prefix : <#>.\n@prefix acl: <http://www.w3.org/ns/auth/acl#>.\n@prefix foaf: <http://xmlns.com/foaf/0.1/>.\n@prefix shrd: <./>.\n@prefix c: </profile/card#>.\n\n:owner\n    a acl:Authorization;\n    acl:accessTo shrd:;\n    acl:agent c:me;\n    acl:mode acl:Control, acl:Read, acl:Write.\n\n:public\n    a acl:Authorization;\n    acl:accessTo shrd:;\n    acl:default shrd:;\n    acl:agentClass foaf:Agent;\n    acl:mode acl:Read, acl:Write.';

  return pubFileBody;
}

// Set up individual key file content
String genIndKeyFileBody() {
  String keyFileBody =
      '@prefix : <#>.\n@prefix foaf: <http://xmlns.com/foaf/0.1/>.\n@prefix terms: <http://purl.org/dc/terms/>.\n@prefix file: <$filePred>.\n@prefix data: <$dataPred>.\n:me\n    a foaf:PersonalProfileDocument;\n    terms:title "Individual Encryption Keys".';

  return keyFileBody;
}

// Set up public key file content
String genPubKeyFileBody(String resUrl, String pubKeyStr) {
  String keyFileBody =
      '<$resUrl> <http://purl.org/dc/terms/title> "Public key";\n    <$pubKeyPred> "$pubKeyStr";';

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
      '@prefix : <#>.\n@prefix foaf: <http://xmlns.com/foaf/0.1/>.\n@prefix solid: <http://www.w3.org/ns/solid/terms#>.\n@prefix vcard: <http://www.w3.org/2006/vcard/ns#>.\n@prefix pro: <./>.\n\npro:card a foaf:PersonalProfileDocument; foaf:maker :me; foaf:primaryTopic :me.\n\n:me\n    solid:oidcIssuer <$issuerUri>;\n    a foaf:Person;\n    vcard:fn "$name";\n    vcard:Gender "$genderPred-$gender";\n    foaf:name "$name".';

  return fileBody;
}

// String updateProfile(String editField, String editContent, Map authData) {
//   profData[editField] = editContent;
//   return genProfFileBody(profData, authData);
// }

// Set up log file content
String genLogFileBody() {
  String logFileBody =
      '@prefix : <#>.\n@prefix foaf: <http://xmlns.com/foaf/0.1/>.\n@prefix terms: <http://purl.org/dc/terms/>.\n@prefix logid: <$logIdPred>.\n@prefix data: <$dataPred>.\n:me\n    a foaf:PersonalProfileDocument;\n    terms:title "Permissions Log".';

  return logFileBody;
}

// Set up log acl file content
String genLogAclBody(String webId, String permFileName) {
  String webIdStr = webId.replaceAll('me', '');
  String logAclFileBody =
      '@prefix : <#>.\n@prefix acl: <http://www.w3.org/ns/auth/acl#>.\n@prefix foaf: <http://xmlns.com/foaf/0.1/>.\n@prefix c: <$webIdStr>.\n\n:owner\n    a acl:Authorization;\n    acl:accessTo <$permFileName>;\n    acl:agent c:me;\n    acl:mode acl:Control, acl:Read, acl:Write.\n\n:public\n    a acl:Authorization;\n    acl:accessTo <$permFileName>;\n    acl:agentClass foaf:Agent;\n    acl:mode acl:Append.';

  return logAclFileBody;
}
