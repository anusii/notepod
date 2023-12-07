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
/// Authors: Anushka Vidanage

library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:podnotes/constants/app.dart';
import 'package:podnotes/constants/rdf_functions.dart';
import 'package:podnotes/constants/turtle_structures.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:solid_auth/solid_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:podnotes/constants/file_structure.dart';

// import 'dart:async';

Future<List> initialStructureTest(Map authData) async {
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];
  Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

  // Get webID
  String webId = decodedToken['webid'];
  bool allExists = true;
  Map resNotExist = {
    'folders': [],
    'files': [],
    'folderNames': [],
    'fileNames': []
  };

  for (String containerName in folders) {
    String resourceUrl = webId.replaceAll('profile/card#me', '$containerName/');
    String dPopToken =
        genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');
    if (await checkResourceExists(resourceUrl, accessToken, dPopToken, false) ==
        'not-exist') {
      allExists = false;
      String resourceUrlStr =
          webId.replaceAll('profile/card#me', containerName);
      resNotExist['folders'].add(resourceUrlStr);
      resNotExist['folderNames'].add(containerName);
    }
  }

  for (var containerName in files.keys) {
    List fileNameList = files[containerName];
    for (String fileName in fileNameList) {
      String resourceUrl =
          webId.replaceAll('profile/card#me', '$containerName/$fileName');
      String dPopToken =
          genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');
      if (await checkResourceExists(
              resourceUrl, accessToken, dPopToken, false) ==
          'not-exist') {
        allExists = false;
        resNotExist['files'].add(resourceUrl);
        resNotExist['fileNames'].add(fileName);
      }
    }
  }

  return [allExists, resNotExist];
}

Future<String> checkResourceExists(
    String resUrl, String accessToken, String dPopToken, bool fileFlag) async {
  String contentType;
  String itemType;
  if (fileFlag) {
    contentType = '*/*';
    itemType = '<http://www.w3.org/ns/ldp#Resource>; rel="type"';
  } else {
    /// This is a directory (container)
    contentType = 'application/octet-stream';
    itemType = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"';
  }

  final response = await http.get(
    Uri.parse(resUrl),
    headers: <String, String>{
      'Content-Type': contentType,
      'Authorization': 'DPoP $accessToken',
      'Link': itemType,
      'DPoP': dPopToken,
    },
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    // If the server did return a 200 OK response,
    // then return true.
    return 'exist';
  } else if (response.statusCode == 404) {
    // If the server did not return a 200 OK response,
    // then return false.
    return 'not-exist';
  } else {
    return 'other-error';
  }
}

// Create a directory or a file
Future<String> createItem(
    bool fileFlag, String itemName, String itemBody, String webId, Map authData,
    {required String fileLoc, String? fileType, bool aclFlag = false}) async {
  String? itemLoc = '';
  String itemSlug = '';
  String itemType = '';
  String contentType = '';

  /*
  - fileFlag -> flag to identify whether the resouce is a file or a directory (eg: true/false)
  - itemName -> name of the creating resource (eg: logs (directory), permissions-log.ttl, permissions-log.ttl.acl)
  - itemBody -> body of the creating resource. String value
  - webId    -> webId of the POD owner
  - authData -> authentication data map
  - fileLoc  -> location of the file or directory (mynotes/newset (for a directory), mynotes/newset/ (for a file))
  - fileType -> type of the file (eg: text/html)
  - aclFlag  -> whether the file is an acl file or not (eg: true/false)
  */

  // Get authentication info
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  // Set up directory or file parameters
  if (fileFlag) {
    // This is a file (resource)
    itemLoc = fileLoc;
    itemSlug = itemName;
    contentType = fileType!;
    itemType = '<http://www.w3.org/ns/ldp#Resource>; rel="type"';
  } else {
    // This is a directory (container)
    itemLoc = fileLoc;
    itemSlug = itemName;
    contentType = 'application/octet-stream';
    itemType = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"';
  }

  String encDataUrl = webId.replaceAll('profile/card#me', itemLoc);
  String dPopToken = genDpopToken(encDataUrl, rsaKeyPair, publicKeyJwk, 'POST');

  final http.Response createResponse;

  if (aclFlag) {
    String aclFileUrl =
        webId.replaceAll('profile/card#me', '$itemLoc$itemName');
    String dPopToken =
        genDpopToken(aclFileUrl, rsaKeyPair, publicKeyJwk, 'PUT');

    // The PUT request will create the acl item in the server
    createResponse = await http.put(
      Uri.parse(aclFileUrl),
      headers: <String, String>{
        'Accept': '*/*',
        'Authorization': 'DPoP $accessToken',
        'Connection': 'keep-alive',
        'Content-Type': 'text/turtle',
        'Content-Length': itemBody.length.toString(),
        'DPoP': dPopToken,
      },
      body: itemBody,
    );
  } else {
    // The POST request will create the item in the server
    createResponse = await http.post(
      Uri.parse(encDataUrl),
      headers: <String, String>{
        'Accept': '*/*',
        'Authorization': 'DPoP $accessToken',
        'Connection': 'keep-alive',
        'Content-Type': contentType,
        'Link': itemType,
        'Slug': itemSlug,
        'DPoP': dPopToken,
      },
      body: itemBody,
    );
  }

  if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return 'ok';
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to create resource! Try again in a while.');
  }
}

Future<String> initialProfileUpdate(
  String profBody,
  Map authData,
  String webId,
) async {
  // Get authentication info
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  String profUrl = webId.replaceAll('#me', '');
  String dPopToken = genDpopToken(profUrl, rsaKeyPair, publicKeyJwk, 'PUT');

  // The PUT request will create the acl item in the server
  final updateResponse = await http.put(
    Uri.parse(profUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'Content-Type': 'text/turtle',
      'Content-Length': profBody.length.toString(),
      'DPoP': dPopToken,
    },
    body: profBody,
  );

  if (updateResponse.statusCode == 200 || updateResponse.statusCode == 205) {
    // If the server did return a 205 Reset response,
    return 'ok';
  } else {
    // If the server did not return a 205 response,
    // then throw an exception.
    throw Exception('Failed to update resource! Try again in a while.');
  }
}

// Get public profile information from webId
Future<String> fetchPubFile(String fileUrl) async {
  final response = await http.get(
    Uri.parse(fileUrl),
    headers: <String, String>{
      'Content-Type': 'text/turtle',
    },
  );

  if (response.statusCode == 200) {
    /// If the server did return a 200 OK response,
    /// then parse the JSON.
    return response.body;
  } else {
    /// If the server did not return a 200 OK response,
    /// then throw an exception.
    throw Exception('Failed to load data! Try again in a while.');
  }
}

Future<String> fetchPrvFile(
  String profCardUrl,
  String accessToken,
  String dPopToken,
) async {
  //return 'This is async function demo';
  final profResponse = await http.get(
    Uri.parse(profCardUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'DPoP': dPopToken,
    },
  );

  if (profResponse.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return profResponse.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    //print(profResponse.body);
    throw Exception('Failed to load profile data! Try again in a while.');
  }
}

Future<String> updateIndKeyFile(String webId, Map authData, String resName,
    String encSessionKey, String encNoteFilePath, String encNoteIv) async {
  String createUpdateRes = '';

  // Get indi key file url
  String keyFileUrl = webId.replaceAll(profCard, '$encDirLoc/$indKeyFile');
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  // Update the file
  // First check if the file already contain the same value
  String dPopTokenKeyFile =
      genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'GET');
  String keyFileContent =
      await fetchPrvFile(keyFileUrl, accessToken, dPopTokenKeyFile);
  Map keyFileDataMap = getFileContent(keyFileContent);

  // Define query parameters
  String prefix1 = 'file: <$podnotesFile>';
  String prefix2 = 'podnotesTerms: <$podnotesTerms>';

  String subject = 'file:$resName';
  String predObjPath = 'podnotesTerms:$pathPred "$encNoteFilePath";';
  String predObjIv = 'podnotesTerms:$ivPred "$encNoteIv";';
  String predObjKey = 'podnotesTerms:$sessionKeyPred "$encSessionKey".';

  // Check if the resource is previously added or not
  if (keyFileDataMap.containsKey(resName)) {
    String existPath = keyFileDataMap[resName][pathPred];
    String existIv = keyFileDataMap[resName][ivPred];
    String existKey = keyFileDataMap[resName][sessionKeyPred];

    // If file does not contain the same encrypted value then delete and update
    // the file
    // NOTE: Public key encryption generates different hashes different time for same plaintext value
    // Therefore this always ends up deleting the previous and adding a new hash
    if (existKey != encSessionKey ||
        existPath != encNoteFilePath ||
        existIv != encNoteIv) {
      String predObjPathPrev = 'podnotesTerms:$pathPred "$existPath";';
      String predObjIvPrev = 'podnotesTerms:$ivPred "$existIv";';
      String predObjKeyPrev = 'podnotesTerms:$sessionKeyPred "$existKey".';

      // Generate update sparql query
      String query =
          'PREFIX $prefix1 PREFIX $prefix2 DELETE DATA {$subject $predObjPathPrev $predObjIvPrev $predObjKeyPrev}; INSERT DATA {$subject $predObjPath $predObjIv $predObjKey};';

      // Generate DPoP token
      String dPopTokenKeyFilePatch =
          genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

      // Run the query
      createUpdateRes = await updateFileByQuery(
          keyFileUrl, accessToken, dPopTokenKeyFilePatch, query);
    } else {
      // If the file contain same values, then no need to run anything
      createUpdateRes = 'ok';
    }
  } else {
    // Generate insert only sparql query
    String query =
        'PREFIX $prefix1 PREFIX $prefix2 INSERT DATA {$subject $predObjPath $predObjIv $predObjKey};';

    // Generate DPoP token
    String dPopTokenKeyFilePatch =
        genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

    // Run the query
    createUpdateRes = await updateFileByQuery(
        keyFileUrl, accessToken, dPopTokenKeyFilePatch, query);
  }

  if (createUpdateRes == 'ok') {
    return createUpdateRes;
  } else {
    throw Exception('Failed to create/update the shared file.');
  }
}

Future<String> updateNoteFile(Map authData, Map notePrevData, Map noteNewData) async {

  // Get indi key file url
  String noteFileUrl = notePrevData['noteFileUrl'] + notePrevData['noteFileName'];
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  // Define previous note data
  String noteTitlePrev = notePrevData['noteTitle'];
  String modifiedDateTimePrev = notePrevData['modifiedDateTime'];
  String encNoteContentPrev = notePrevData['encContent'];
  String encIvPrev = notePrevData['encIv'];

  // Define new note data
  String noteTitleNew = noteNewData['noteTitle'];
  String modifiedDateTimeNew = noteNewData['modifiedDateTime'];
  String encNoteContentNew = noteNewData['encContent'];
  String encIvNew = noteNewData['encIv'];

  // Define query parameters
  String prefix1 = ': <#>';
  String prefix2 = 'podnotesTerms: <$podnotesTerms>';

  String subject = ':me';

  // Previous data
  String predObjModifiedTimePrev = 'podnotesTerms:$modifiedDateTimePred "$modifiedDateTimePrev";';
  String predObjIvPrev = 'podnotesTerms:$ivPred "$encIvPrev";';
  String predObjNoteTitlePrev = 'podnotesTerms:$noteTitlePred "$noteTitlePrev";';
  String predObjEncNoteContentPrev = 'podnotesTerms:$encNoteContentPred "$encNoteContentPrev".';

  // New data
  String predObjModifiedTime = 'podnotesTerms:$modifiedDateTimePred "$modifiedDateTimeNew";';
  String predObjIv = 'podnotesTerms:$ivPred "$encIvNew";';
  String predObjNoteTitle = 'podnotesTerms:$noteTitlePred "$noteTitleNew";';
  String predObjEncNoteContent = 'podnotesTerms:$encNoteContentPred "$encNoteContentNew".';

  // Generate update sparql query
  String query =
      'PREFIX $prefix1 PREFIX $prefix2 DELETE DATA {$subject $predObjModifiedTimePrev $predObjIvPrev $predObjNoteTitlePrev $predObjEncNoteContentPrev}; INSERT DATA {$subject $predObjModifiedTime $predObjIv $predObjNoteTitle $predObjEncNoteContent};';

  // Generate DPoP token
  String dPopTokenKeyFilePatch =
      genDpopToken(noteFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

  // Run the query
  String fileUpdateRes = await updateFileByQuery(
      noteFileUrl, accessToken, dPopTokenKeyFilePatch, query);

  if (fileUpdateRes == 'ok') {
    return fileUpdateRes;
  } else {
    throw Exception('Failed to create/update the shared file.');
  }
}

Future<String> updateFileByQuery(
  String fileUrl,
  String accessToken,
  String dPopToken,
  String query,
) async {
  final editResponse = await http.patch(
    Uri.parse(fileUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'Content-Type': 'application/sparql-update',
      'Content-Length': query.length.toString(),
      'DPoP': dPopToken,
    },
    body: query,
  );

  if (editResponse.statusCode == 200 || editResponse.statusCode == 205) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return 'ok';
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to write profile data! Try again in a while.');
  }
}

Future<List> getNoteList(Map authData, String notesUrl) async {

  List fileList = [];

  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  var resList = await getResourceList(
      authData,
      notesUrl,
    );
  
  List noteList = resList[1];

  for (var i = 0; i < noteList.length; i++) {
      String fileItem = noteList[i];
      String fileItemUrl = notesUrl + fileItem;

      // Generate DPoP token
      String dPopTokenNoteFile =
          genDpopToken(fileItemUrl, rsaKeyPair, publicKeyJwk, 'GET');
      
      // Get note file content
      String noteFileContent = await fetchPrvFile(fileItemUrl, accessToken, dPopTokenNoteFile);
      Map noteFileContentMap = getFileContent(noteFileContent);

      String noteTitle = noteFileContentMap['noteTitle'][1];
      String noteDateTime = DateFormat('yyyy-MM-dd hh:mm:ssa').format(DateTime.parse(noteFileContentMap['createdDateTime'][1]));

      fileList.add([noteTitle, noteDateTime, fileItem]);
  }
  
  return fileList;

}

Future<List> getSharedNotesList(Map authData, String webId) async {

  List sharedFileList = [];

  String sharedNotesDirLoc = webId.replaceAll(profCard, '$sharedDirLoc/');

  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  var resList = await getResourceList(
      authData,
      sharedNotesDirLoc,
    );
  
  List sharedNotesDirList = resList[0];

  for (var i = 0; i < sharedNotesDirList.length; i++) {
      String sharedDir = sharedNotesDirList[i];

      String sharedNotesFileLoc = '$sharedNotesDirLoc$sharedDir/$sharedKeyFile';

      // Generate DPoP token
      String dPopTokenSharedNoteFile =
          genDpopToken(sharedNotesFileLoc, rsaKeyPair, publicKeyJwk, 'GET');
      
      // Get note file content
      String shredNoteFileContent = await fetchPrvFile(sharedNotesFileLoc, accessToken, dPopTokenSharedNoteFile);
      Map sharedNoteFileContentMap = getEncFileContent(shredNoteFileContent);

      if(sharedNoteFileContentMap.isNotEmpty){
        for (var fileName in sharedNoteFileContentMap.keys) {
          // Get shared file information (all encrypted using receipient's public key)
          String ownerWebIdEnc = sharedNoteFileContentMap[fileName][webIdPred];
          String filePathEnc = sharedNoteFileContentMap[fileName][pathPred];
          String fileSessionKeyEnc = sharedNoteFileContentMap[fileName][sharedKeyPred];
          String fileAccListEnc = sharedNoteFileContentMap[fileName][accessListPred]; 

          // Decrypt the data

          // Get encryption key and private key
          String keyFileUrl =
              webId.replaceAll(profCard, '$encDirLoc/$encKeyFile');
          String keydPopToken =
              genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'GET');
          String keyFileInfo =
              await fetchPrvFile(keyFileUrl, accessToken, keydPopToken);

          // Read file content using RDFlib
          Map keyFileMap = getFileContent(keyFileInfo);

          // Get the master key from secure storage
          String secureKey = await secureStorage.read(key: webId) ?? '';
          String masterKeyStr =
              sha256.convert(utf8.encode(secureKey)).toString().substring(0, 32);

          // Setup AES encrypter
          final key = encrypt.Key.fromUtf8(masterKeyStr);
          final iv = encrypt.IV.fromBase64(
            keyFileMap[ivPred][1],
          );

          final encrypter =
              encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

          // Decrypt private key
          final ecc = encrypt.Encrypted.from64(keyFileMap[prvKeyPred][1]);
          final prvKeyStr = encrypter.decrypt(ecc, iv: iv);

          // Use POD's private key to decrypt shared file data
          final parser = encrypt.RSAKeyParser();
          final prvKey = parser.parse(prvKeyStr) as RSAPrivateKey;
          final encrypterPrv = encrypt.Encrypter(
            encrypt.RSA(privateKey: prvKey),
          );

          final sharedWebId = encrypterPrv.decrypt(
            encrypt.Key.fromBase64(
              ownerWebIdEnc,
            ),
          );

          final sharedFilePath = encrypterPrv.decrypt(
            encrypt.IV.fromBase64(
              filePathEnc,
            ),
          );

          final sharedKey = encrypterPrv.decrypt(
            encrypt.Key.fromBase64(
              fileSessionKeyEnc,
            ),
          );

          final sharedAccList = encrypterPrv.decrypt(
            encrypt.Key.fromBase64(
              fileAccListEnc,
            ),
          );

          sharedFileList.add([fileName, sharedWebId, sharedFilePath, sharedAccList, sharedKey]);
        }
      }
  }
  
  return sharedFileList;

}

// Get the list of resources (folders and files) in a specific location
Future<List> getResourceList(
  Map authData,
  String resourceUrl,
) async {
  List<String> foldersList = [];
  List<String> filesList = [];
  String homePage;

  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];

  String accessToken = authData['accessToken'];

  // Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

  String dPopTokenHome =
      genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');

  final profResponse = await http.get(
    Uri.parse(resourceUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'DPoP': dPopTokenHome,
    },
  );

  if (profResponse.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    homePage = profResponse.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load profile data! Try again in a while.');
  }

  PodProfile homePageFile = PodProfile(homePage);

  List rdfDataPrefixList = homePageFile.dividePrvRdfData();
  List rdfDataList = rdfDataPrefixList.first;

  for (var i = 0; i < rdfDataList.length; i++) {
    if (rdfDataList[i].contains('ldp:contains')) {
      var itemList = rdfDataList[i].split('<');

      for (var j = 0; j < itemList.length; j++) {
        // if (containerList.length >= 200) {
        //   break;
        // }
        if (itemList[j].contains('/>')) {
          var item = itemList[j].replaceAll('/>,', '');
          item = item.replaceAll('/>.', '');
          item = item.replaceAll(' ', '');
          // if((item.contains('H')) | (item.contains('R'))){
          //   containerList.add(item);
          // }
          foldersList.add(item);
        } else if (itemList[j].contains('>')) {
          var item = itemList[j].replaceAll('>,', '');
          item = item.replaceAll('>.', '');
          item = item.replaceAll(' ', '');
          filesList.add(item);
        }
      }
    }
  }

  return [foldersList, filesList];
}

// Get the note content, derypt and return it
Future<Map> getNoteContent(
  Map authData,
  String webId,
  String noteFileName,
) async {
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];
  String noteUrl = webId.replaceAll(profCard, '$myNotesDirLoc/$noteFileName');
  String dPopTokenNote = genDpopToken(noteUrl, rsaKeyPair, publicKeyJwk, 'GET');

  String fileContent = await fetchPrvFile(
    noteUrl,
    accessToken,
    dPopTokenNote,
  );

  Map noteData = {};
  Map noteContent = getFileContent(fileContent);

  // Decrypt the note content
  // Get the master key
  String secureKey = await secureStorage.read(key: webId) ?? '';
  String masterKeyStr =
      sha256.convert(utf8.encode(secureKey)).toString().substring(0, 32);

  // Get the individual key
  String indFileUrl = webId.replaceAll(
    profCard,
    '$encDirLoc/$indKeyFile',
  );

  String indKeysPopToken = genDpopToken(
    indFileUrl,
    rsaKeyPair,
    publicKeyJwk,
    'GET',
  );
  String indKeysFileInfo = await fetchPrvFile(
    indFileUrl,
    accessToken,
    indKeysPopToken,
  );

  Map indKeysFileMap = getEncFileContent(indKeysFileInfo);
  String indKeyEncVal = '';
  String indKeyIvz = '';
  if (indKeysFileMap.containsKey(noteFileName)) {
    indKeyEncVal = indKeysFileMap[noteFileName][sessionKeyPred];
    indKeyIvz = indKeysFileMap[noteFileName][ivPred];
  } else {
    throw Exception(
      'No individual key recorded for the aggregated data file',
    );
  }

  // Setup AES encrypter
  final key = encrypt.Key.fromUtf8(masterKeyStr);
  final iv = encrypt.IV.fromBase64(indKeyIvz);
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

  // Decrypt individual key
  final ecc = encrypt.Encrypted.from64(indKeyEncVal);
  String indKeyStr = encrypter.decrypt(ecc, iv: iv);

  // Now use decrypted individual key to decrypt note data
  String noteIv = noteContent[ivPred][1];
  String noteEncVal = noteContent[encNoteContentPred][1];
  final keyInd = encrypt.Key.fromBase64(indKeyStr);
  final ivInd = encrypt.IV.fromBase64(noteIv);
  final encrypterInd =
      encrypt.Encrypter(encrypt.AES(keyInd, mode: encrypt.AESMode.cbc));

  // Decrypt data
  final eccInd = encrypt.Encrypted.from64(noteEncVal);
  final noteContentStr = encrypterInd.decrypt(eccInd, iv: ivInd);

  noteData['noteTitle'] = noteContent['noteTitle'][1].replaceAll('_', ' ');
  noteData['createdDateTime'] = DateFormat('yyyy-MM-dd hh:mm:ssa')
      .format(DateTime.parse(noteContent['createdDateTime'][1]));
  noteData['modifiedDateTime'] = noteContent['modifiedDateTime'][1];
  noteData['noteContent'] = noteContentStr;
  noteData['noteFileName'] = noteFileName;
  noteData['noteFileUrl'] = webId.replaceAll(profCard, '$myNotesDirLoc/');
  noteData['encSessionKey'] = indKeyStr;
  noteData['encContent'] = noteEncVal;
  noteData['encIv'] = noteIv;

  return noteData;
}