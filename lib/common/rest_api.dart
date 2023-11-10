// Flutter imports.
import 'dart:async';

// Package imports.
import 'package:solid_auth/solid_auth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

// Project imports.
import 'package:podnotes/common/app.dart';

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
          webId.replaceAll('profile/card#me', '$containerName');
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
      'DPoP': '$dPopToken',
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
