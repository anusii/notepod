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

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:solid_auth/solid_auth.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/crypto.dart';
import 'package:notepod/constants/file_structure.dart';
import 'package:notepod/constants/rdf_functions.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/widgets/err_dialogs.dart';

Future<Map> getPermission(
    Map authData, String resourceName, String resourseUrl) async {
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  String resourceAcl = '$resourseUrl$resourceName.acl';

  String dPopToken = genDpopToken(resourceAcl, rsaKeyPair, publicKeyJwk, 'GET');

  String fileInfo = '';

  // [fileInfo] is set as an empty string if the file is not shared.
  // [fileInfo] is set as an empty string if [resourceAcl] is the
  // address of the folder.
  try {
    fileInfo = await fetchPrvFile(resourceAcl, accessToken, dPopToken);
  } catch (e) {
    fileInfo = '';
  }

  AclResource aclResFile = AclResource(fileInfo);

  List userPermRes = aclResFile.divideAclData();
  Map userNameMap = userPermRes.first;
  Map permMap = userPermRes[1];
  Map userPermMap = {};

  for (var accessStr in permMap.keys) {
    List resourceList = permMap[accessStr];
    Set resourceSet = resourceList.first;
    Set userSet = resourceList[1];
    Set accessSet = resourceList[2];

    if (resourceSet.contains('<$resourceName>')) {
      for (String userStr in userSet) {
        String userWebId = userNameMap[userStr];
        String accessStr = accessSet.join(', ').replaceAll('acl:', '');
        userPermMap[userWebId] = accessStr;
      }
    }
  }

  return userPermMap;
}

Future<void> addPermission(
  BuildContext context,
  TextEditingController permissionInputController,
  String accessToken,
  Map authData,
  String resourceName,
  String resourceUrl,
  List selectedItems,
  String webId,
) async {
  String permissionWebId = permissionInputController.text;

  if (permissionWebId.isNotEmpty && permissionWebId.contains('https://')) {
    if (await checkPublicProf(permissionWebId)) {
      String res = await setPermission(accessToken, authData, resourceName,
          resourceUrl, permissionWebId, selectedItems);

      // Get the file content and check if the file is encrypted
      var rsaInfo = authData['rsaInfo'];
      var rsaKeyPair = rsaInfo['rsa'];
      var publicKeyJwk = rsaInfo['pubKeyJwk'];

      String dPopToken =
          genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');
      String encFileContent =
          await fetchPrvFile(resourceUrl, accessToken, dPopToken);

      bool encryptedFlag = false;
      Map prvDataMap = getFileContent(encFileContent);
      if (prvDataMap.containsKey(encNoteContentPred)) {
        encryptedFlag = true;
      }

      /// If the file is encrypted
      if (encryptedFlag) {
        // Get user's encryption key.

        //FlutterSecureStorage _storage = FlutterSecureStorage();
        String secureKey = await secureStorage.read(key: webId) ?? '';
        String encKey =
            sha256.convert(utf8.encode(secureKey)).toString().substring(0, 32);

        // Get the individual encryption key for the file
        String indKeyFileLoc =
            webId.replaceAll('profile/card#me', '$encDirLoc/$indKeyFile');
        String dPopTokenKeyFile =
            genDpopToken(indKeyFileLoc, rsaKeyPair, publicKeyJwk, 'GET');
        String keyFileContent =
            await fetchPrvFile(indKeyFileLoc, accessToken, dPopTokenKeyFile);
        Map keyFileDataMap = getEncFileContent(keyFileContent);
        String fileKeyInd = keyFileDataMap[resourceName][sessionKeyPred];

        // Decrypt the individual key using master key
        final masterKey = encrypt.Key.fromUtf8(encKey);
        final ivInd =
            encrypt.IV.fromBase64(keyFileDataMap[resourceName][ivPred]);
        final encrypterInd = encrypt.Encrypter(
            encrypt.AES(masterKey, mode: encrypt.AESMode.cbc));
        final eccInd = encrypt.Encrypted.from64(fileKeyInd);
        String plainKeyInd = encrypterInd.decrypt(eccInd, iv: ivInd);

        // Get recipient's public key
        var otherPubKey = await fetchOtherPubKey(authData, permissionWebId);
        otherPubKey = otherPubKey.replaceAll('"', '');
        otherPubKey = genPubKeyStr(otherPubKey);

        // Encrypt individual key, file path, access list, and sender's webId using recipient's public key
        final parser = encrypt.RSAKeyParser();
        final pubKey = parser.parse(otherPubKey) as RSAPublicKey;
        final encrypterPub = encrypt.Encrypter(encrypt.RSA(publicKey: pubKey));
        final encShareKey = encrypterPub.encrypt(plainKeyInd).base64.toString();
        final encSharePath =
            encrypterPub.encrypt(resourceUrl).base64.toString();

        selectedItems.sort();
        String accessListStr = selectedItems.join(',');
        final encSharedAccess =
            encrypterPub.encrypt(accessListStr).base64.toString();

        final encSharedWebId = encrypterPub.encrypt(webId).base64.toString();

        // Get username to create a directory
        List webIdContent = webId.split('/');
        String dirName = webIdContent[3];

        // Copying shared key to recipient's POD
        String shareRes = await copySharedKey(
            permissionWebId,
            dirName,
            authData,
            resourceName,
            resourceUrl,
            encShareKey,
            encSharePath,
            encSharedAccess,
            encSharedWebId);

        if (shareRes != 'ok') {
          debugPrint('Something went wrong!');
        }
      }

      //String res = 'ok';

      if (res == 'ok') {
        // Update log files of the relevant PODs
        // Here we need to update two log files
        // File owner and permission recipient
        String accessListStr = selectedItems.join(',');
        String dateTimeStr =
            DateFormat('yyyyMMddTHHmmss').format(DateTime.now()).toString();
        String logStr =
            '$dateTimeStr;$resourceUrl;$webId;grant;$webId;$permissionWebId;${accessListStr.toLowerCase()}';

        // Write to log files of all actors in the permission
        // action
        String permLogUrlOwner = webId.replaceAll(
          profCard,
          '$logDirLoc/$permLogFile',
        );

        String permLogUrlReceiver = permissionWebId.replaceAll(
          profCard,
          '$logDirLoc/$permLogFile',
        );

        String permAppendRes1 = await addPermLogLine(
          permLogUrlOwner,
          authData,
          logStr,
          dateTimeStr,
        );

        String permAppendRes2 = await addPermLogLine(
          permLogUrlReceiver,
          authData,
          logStr,
          dateTimeStr,
        );

        if (permAppendRes1 != 'ok' || permAppendRes2 != 'ok') {
          debugPrint('Something went wrong with logging your permission!');
        }

        // ignore: use_build_context_synchronously
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => NavigationScreen(
        //             webId: webId,
        //             authData: authData,
        //             page: 'listNotes',
        //           )),
        //   (Route<dynamic> route) =>
        //       false, // This predicate ensures all previous routes are removed
        // );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        showErrDialog(context, 'Error occurred. Please try again in a while');
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      showErrDialog(context, 'Error: Please enter a valid webID');
    }
  } else {
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    showErrDialog(context, 'Error: Please enter a valid webID');
  }
}

Future<bool> checkPublicProf(String profUrl) async {
  String profData = await fetchPubFile(profUrl);

  return (profData.isNotEmpty);
}

Future<String> setPermission(
    String accessToken,
    Map authData,
    String resourceName,
    String resourseUrl,
    String permissionWebId,
    List selectedPermItems) async {
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];

  String resourceAcl = '$resourseUrl.acl';

  String dPopToken = genDpopToken(resourceAcl, rsaKeyPair, publicKeyJwk, 'GET');
  String fileInfo = await fetchPrvFile(resourceAcl, accessToken, dPopToken);

  AclResource aclResFile = AclResource(fileInfo);

  List userPermRes = aclResFile.divideAclData();
  Map userNameMap = userPermRes.first;
  Map userPermMap = userPermRes[1];

  List userPrefixList = [];
  userNameMap.forEach((key, val) => userPrefixList.add(key));

  List userUrlList = [];
  String newUserPrefix = '';
  if (userNameMap.isNotEmpty) {
    userNameMap.forEach((key, val) => userUrlList.add(userNameMap[key]));
    String permissionWebIdStr = '<${permissionWebId.trim()}>';
    permissionWebIdStr = permissionWebIdStr.replaceAll('#me', '#');
    if (!userUrlList.contains(permissionWebIdStr)) {
      newUserPrefix = 'c${userPrefixList.length - 1}:';
      int i = (userPrefixList.length - 1);
      while (userPrefixList.contains(newUserPrefix)) {
        i += 1;
        newUserPrefix = 'c$i:';
      }
    }
    if (newUserPrefix.isNotEmpty) {
      userNameMap[newUserPrefix] = permissionWebIdStr;
    }
  } else {
    newUserPrefix = '<${permissionWebId.trim()}>';
  }

  selectedPermItems.sort();
  String newAccessStr = selectedPermItems.join('');

  if (userPermMap.containsKey(newAccessStr)) {
    List resouceList = userPermMap[newAccessStr];
    Set resourceSet = resouceList.first;
    Set userSet = resouceList[1];
    Set accessSet = resouceList[2];
    resourceSet.add('<$resourceName>');
    userSet.add(newUserPrefix);
    userPermMap[newAccessStr] = [resourceSet, userSet, accessSet];
  } else {
    Set accessSet = {};
    for (var element in selectedPermItems) {
      accessSet.add('acl:$element');
    }
    userPermMap[newAccessStr] = [
      {'<$resourceName>'},
      {newUserPrefix},
      accessSet
    ];
  }

  String aclPrefixTemp =
      '''@prefix : <#>.\n@prefix acl: <http://www.w3.org/ns/auth/acl#>.\n@prefix foaf: <http://xmlns.com/foaf/0.1/>.\n''';

  if (userNameMap.isNotEmpty) {
    for (var userPrefix in userNameMap.keys) {
      var userWebId = userNameMap[userPrefix];
      String prefixLineStr = '${'${'@prefix ' + userPrefix} ' + userWebId}.\n';
      aclPrefixTemp += prefixLineStr;
    }
  }

  String aclBodyTemp = '';

  for (var accessStr in userPermMap.keys) {
    List resouceList = userPermMap[accessStr];
    Set resourceSet = resouceList.first;
    Set userSet = resouceList[1];
    Set accessSet = resouceList[2];

    String resourceStr = resourceSet.join(', ');
    Set userStrSet = {};
    for (var user in userSet) {
      userStrSet.add(user + 'me');
    }
    String userStr = userStrSet.join(', ');
    String accessModeStr = accessSet.join(', ');

    String accessBlock =
        ':$accessStr\n    a acl:Authorization;\n    acl:accessTo $resourceStr;\n    acl:agent $userStr;\n    acl:mode $accessModeStr.\n';
    aclBodyTemp += accessBlock;
  }

  // """
  // :ControlReadWrite
  //     a acl:Authorization;
  //     acl:accessTo <$resourseUrl>;
  //     acl:agent c:me;
  //     acl:mode acl:Control, acl:Read, acl:Write.
  // """;

  String aclNewStr = '$aclPrefixTemp\n$aclBodyTemp';

  // String bodyStr = 'dsfsd';

  // final deleteResponse = await http.delete(
  //   Uri.parse(resourceAcl),
  //   headers: <String, String>{
  //     'Accept': '*/*',
  //     'Authorization': 'DPoP $accessToken',
  //     'Connection': 'keep-alive',
  //     'Content-Type': 'text/turtle',
  //     'DPoP': dPopToken,
  //   },
  // );

  String dPopTokenPut =
      genDpopToken(resourceAcl, rsaKeyPair, publicKeyJwk, 'PUT');

  final editResponse = await http.put(
    Uri.parse(resourceAcl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'Content-Type': 'text/turtle',
      'Content-Length': aclNewStr.length.toString(),
      'DPoP': dPopTokenPut,
    },
    body: aclNewStr,
  );

  if (editResponse.statusCode == 201 || editResponse.statusCode == 205) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return 'ok';
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to write profile data! Try again in a while.');
  }
}

Future<String> fetchOtherPubKey(Map authData, String otherWebId) async {
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  // Get profile
  String pubKeyUrl =
      otherWebId.replaceAll('profile/card#me', '$sharingDirLoc/$pubKeyFile');
  String dPopTokenPub =
      genDpopToken(pubKeyUrl, rsaKeyPair, publicKeyJwk, 'GET');

  String pubKeyRes = await fetchPrvFile(pubKeyUrl, accessToken, dPopTokenPub);

  String otherPubKey = '';
  PodProfile rdfData = PodProfile(pubKeyRes);
  var prvRdfData = rdfData.dividePrvRdfData().first;

  for (String t in prvRdfData) {
    if (t.contains('#pubKey')) {
      var pubKeyVal = t.split('>').last.trim();
      otherPubKey = pubKeyVal;
    }
  }

  return otherPubKey;
}

Future<String> copySharedKey(
  String webId,
  String dirName,
  Map authData,
  String resName,
  String resUrl,
  String encSharedKey,
  String encSharedPath,
  String encSharedAccess,
  String encSharedWebId,
) async {
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  /// Create a directory if not exists
  String dirUrl =
      webId.replaceAll('profile/card#me', '$sharedDirLoc/$dirName/');

  String dPopTokenDir = genDpopToken(dirUrl, rsaKeyPair, publicKeyJwk, 'GET');

  if (await checkResourceExists(dirUrl, accessToken, dPopTokenDir, false) ==
      'not-exist') {
    var dirCreateRes = await createItem(
        false, dirName, dirBody, webId, authData,
        fileLoc: '$sharedDirLoc/');

    if (dirCreateRes != 'ok') {
      throw Exception('Failed to create resource! Try again in a while.');
    }
  }

  /// Get shared key file url.
  String keyFileUrl = webId.replaceAll(
      'profile/card#me', '$sharedDirLoc/$dirName/$sharedKeyFile');

  String dPopTokenKeyFile =
      genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'GET');

  /// Create file if not exists
  String createUpdateRes;
  if (await checkResourceExists(
          keyFileUrl, accessToken, dPopTokenKeyFile, false) ==
      'not-exist') {
    String keyFileBody =
        '@prefix : <#>.\n@prefix foaf: <http://xmlns.com/foaf/0.1/>.\n@prefix terms: <http://purl.org/dc/terms/>.\n@prefix file: <$notepodFile>.\n@prefix notepodTerms: <$notepodTerms>.\n:me\n    a foaf:PersonalProfileDocument;\n    terms:title "Shared Encryption Keys".\nfile:$resName\n    notepodTerms:$webIdPred "$encSharedWebId";\n    notepodTerms:$pathPred "$encSharedPath";\n    notepodTerms:$accessListPred "$encSharedAccess";\n    notepodTerms:$sharedKeyPred "$encSharedKey".';

    /// Update the ttl file with the shared info
    createUpdateRes = await createItem(
        true, sharedKeyFile, keyFileBody, webId, authData,
        fileLoc: '$sharedDirLoc/$dirName', fileType: 'text/turtle');
  } else {
    /// Update the file
    /// First check if the file already contain the same value
    String dPopTokenKeyFile =
        genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'GET');
    String keyFileContent =
        await fetchPrvFile(keyFileUrl, accessToken, dPopTokenKeyFile);
    Map keyFileDataMap = getEncFileContent(keyFileContent);

    /// Define query parameters
    String prefix1 = 'file: <$notepodFile>';
    String prefix2 = 'notepodTerms: <$notepodTerms>';

    String subject = 'file:$resName';
    String predObjWebId = 'notepodTerms:$webIdPred "$encSharedWebId";';
    String predObjPath = 'notepodTerms:$pathPred "$encSharedPath";';
    String predObjAcc = 'notepodTerms:$accessListPred "$encSharedAccess";';
    String predObjKey = 'notepodTerms:$sharedKeyPred "$encSharedKey".';

    /// Check if the resource is previously added or not
    if (keyFileDataMap.containsKey(resName)) {
      String existWebId = keyFileDataMap[resName][webIdPred];
      String existKey = keyFileDataMap[resName][sharedKeyPred];
      String existPath = keyFileDataMap[resName][pathPred];
      String existAcc = keyFileDataMap[resName][accessListPred];

      /// If file does not contain the same encrypted value then delete and update
      /// the file
      /// NOTE: Public key encryption generates different hashes different time for same plaintext value
      /// Therefore this always ends up deleting the previous and adding a new hash
      if (existKey != encSharedKey ||
          existPath != encSharedPath ||
          existAcc != encSharedAccess ||
          existWebId != encSharedWebId) {
        String predObjWebIdPrev = 'data:$webIdPred "$existWebId";';
        String predObjPathPrev = 'data:$pathPred "$existPath";';
        String predObjAccPrev = 'data:$accessListPred "$existAcc";';
        String predObjKeyPrev = 'data:$sharedKeyPred "$existKey".';

        /// Generate update sparql query
        String query =
            'PREFIX $prefix1 PREFIX $prefix2 DELETE DATA {$subject $predObjWebIdPrev $predObjPathPrev $predObjAccPrev $predObjKeyPrev}; INSERT DATA {$subject $predObjWebId $predObjPath $predObjAcc $predObjKey};';

        /// Generate DPoP token
        String dPopTokenKeyFilePatch =
            genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

        /// Run the query
        createUpdateRes = await updateFileByQuery(
            keyFileUrl, accessToken, dPopTokenKeyFilePatch, query);
      } else {
        /// If the file contain same values, then no need to run anything
        debugPrint('Existing key is the same as new one');
        createUpdateRes = 'ok';
      }
    } else {
      /// Generate insert only sparql query
      String query =
          'PREFIX $prefix1 PREFIX $prefix2 INSERT DATA {$subject $predObjWebId $predObjPath $predObjAcc $predObjKey};';

      /// Generate DPoP token
      String dPopTokenKeyFilePatch =
          genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

      /// Run the query
      createUpdateRes = await updateFileByQuery(
          keyFileUrl, accessToken, dPopTokenKeyFilePatch, query);
    }

    //developer.log(createUpdateRes);
  }

  if (createUpdateRes == 'ok') {
    return createUpdateRes;
  } else {
    throw Exception('Failed to create/update the shared file.');
  }
}

Future<String> addPermLogLine(
  String permFileUrl,
  Map authData,
  String permLineStr,
  String dateTimeStr,
) async {
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];
  String dPopToken =
      genDpopToken(permFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

  String dataQuery =
      'INSERT DATA {<$notepodLogId$dateTimeStr> <$notepodTerms#log> "<$permLineStr>"};';

  final editResponse = await http.patch(
    Uri.parse(permFileUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'Content-Type': 'application/sparql-update',
      'Content-Length': dataQuery.length.toString(),
      'DPoP': dPopToken,
    },
    body: dataQuery,
  );

  if (editResponse.statusCode == 200 || editResponse.statusCode == 205) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return 'ok';
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    debugPrint(editResponse.statusCode.toString());
    debugPrint(editResponse.body);
    throw Exception('Failed to write log data! Try again in a while.');
  }
}

Future<String> deletePermission(
  String accessToken,
  Map authData,
  String resourseUrl,
  String deleteWebId,
  List deletePermItems,
) async {
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];

  String resourceAcl = '$resourseUrl.acl';

  String dPopToken = genDpopToken(resourceAcl, rsaKeyPair, publicKeyJwk, 'GET');
  String fileInfo = await fetchPrvFile(resourceAcl, accessToken, dPopToken);

  AclResource aclResFile = AclResource(fileInfo);

  List userPermRes = aclResFile.divideAclData();
  Map userNameMap = userPermRes.first;
  Map userPermMap = userPermRes[1];

  Map newUserNameMap = {};
  String delUserPrefix = '';
  if (userNameMap.isNotEmpty) {
    for (var userPrefix in userNameMap.keys) {
      var userWebId = userNameMap[userPrefix];
      if (deleteWebId != userWebId) {
        newUserNameMap[userPrefix] = userWebId;
      } else {
        delUserPrefix = userPrefix;
      }
    }
  }

  deletePermItems.sort();
  String delAccessStr = deletePermItems.join('');
  Map newUserPermMap = {};
  for (var accessStr in userPermMap.keys) {
    List resouceList = userPermMap[accessStr];

    if (accessStr == delAccessStr) {
      Set resourceSet = resouceList.first;
      Set userSet = resouceList[1];
      Set accessSet = resouceList[2];

      if (delUserPrefix.isNotEmpty) {
        userSet.remove(delUserPrefix);
      } else {
        userSet.remove(deleteWebId);
      }

      if (userSet.isNotEmpty) {
        newUserPermMap[accessStr] = [resourceSet, userSet, accessSet];
      }
    } else {
      newUserPermMap[accessStr] = resouceList;
    }
  }

  String aclPrefixTemp =
      '''@prefix : <#>.\n@prefix acl: <http://www.w3.org/ns/auth/acl#>.\n@prefix foaf: <http://xmlns.com/foaf/0.1/>.\n''';

  if (newUserNameMap.isNotEmpty) {
    for (var userPrefix in newUserNameMap.keys) {
      var userWebId = newUserNameMap[userPrefix];
      String prefixLineStr = '${'${'@prefix ' + userPrefix} ' + userWebId}.\n';
      aclPrefixTemp += prefixLineStr;
    }
  }

  String aclBodyTemp = '';

  for (var accessStr in newUserPermMap.keys) {
    List resouceList = newUserPermMap[accessStr];
    Set resourceSet = resouceList.first;
    Set userSet = resouceList[1];
    Set accessSet = resouceList[2];

    String resourceStr = resourceSet.join(', ');
    Set userStrSet = {};
    for (var user in userSet) {
      userStrSet.add(user + 'me');
    }
    String userStr = userStrSet.join(', ');
    String accessModeStr = accessSet.join(', ');

    String accessBlock =
        ':$accessStr\n    a acl:Authorization;\n    acl:accessTo $resourceStr;\n    acl:agent $userStr;\n    acl:mode $accessModeStr.\n';
    aclBodyTemp += accessBlock;
  }

  String aclNewStr = '$aclPrefixTemp\n$aclBodyTemp';

  String dPopTokenPut =
      genDpopToken(resourceAcl, rsaKeyPair, publicKeyJwk, 'PUT');

  final editResponse = await http.put(
    Uri.parse(resourceAcl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'Content-Type': 'text/turtle',
      'Content-Length': aclNewStr.length.toString(),
      'DPoP': dPopTokenPut,
    },
    body: aclNewStr,
  );

  if (editResponse.statusCode == 201 || editResponse.statusCode == 205) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return 'ok';
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to write profile data! Try again in a while.');
  }
}

Future<String> removeSharedKey(
  String webId,
  String dirName,
  Map authData,
  String resName,
) async {
  // Get shared key file url
  String keyFileUrl = webId.replaceAll(
    profCard,
    '$sharedDirLoc/$dirName/$sharedKeyFile',
  );
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  String dPopTokenKeyFile =
      genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'GET');

  String createUpdateRes = 'ok';

  if (await checkResourceExists(
          keyFileUrl, accessToken, dPopTokenKeyFile, false) ==
      'exist') {
    // Get the file content first

    String keyFileContent =
        await fetchPrvFile(keyFileUrl, accessToken, dPopTokenKeyFile);
    Map keyFileDataMap = getEncFileContent(keyFileContent);

    // Check if the resource is previously added or not
    if (keyFileDataMap.containsKey(resName)) {
      // Define query parameters
      String prefix1 = 'file: <$notepodFile>';
      String prefix2 = 'notepodTerms: <$notepodTerms>';

      String subject = 'file:$resName';
      String existKey = keyFileDataMap[resName][sharedKeyPred];
      String existPath = keyFileDataMap[resName][pathPred];
      String existAcc = keyFileDataMap[resName][accessListPred];
      String existWebId = keyFileDataMap[resName][webIdPred];

      String predObjWebIdPrev = 'notepodTerms:$webIdPred "$existWebId";';
      String predObjPathPrev = 'notepodTerms:$pathPred "$existPath";';
      String predObjAccPrev = 'notepodTerms:$accessListPred "$existAcc";';
      String predObjKeyPrev = 'notepodTerms:$sharedKeyPred "$existKey".';

      // Generate update sparql query
      String query =
          'PREFIX $prefix1 PREFIX $prefix2 DELETE DATA {$subject $predObjWebIdPrev $predObjPathPrev $predObjAccPrev $predObjKeyPrev};';

      // Generate DPoP token
      String dPopTokenKeyFilePatch =
          genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

      // Run the query
      createUpdateRes = await updateFileByQuery(
        keyFileUrl,
        accessToken,
        dPopTokenKeyFilePatch,
        query,
      );

      // if (existKey != encSharedKey || existPath != encSharedPath) {
      //   print(
      //       'Either shared key or path is not the same as actually key or path');
      // }
    }
  }

  if (createUpdateRes == 'ok') {
    return createUpdateRes;
  } else {
    throw Exception('Failed to create/update the shared file.');
  }
}
