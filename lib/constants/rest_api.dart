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

import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:solid_auth/solid_auth.dart';

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

  for (String containerName in FOLDERS) {
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

  for (var containerName in FILES.keys) {
    List fileNameList = FILES[containerName];
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
