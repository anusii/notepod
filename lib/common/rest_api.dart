// Flutter imports.
import 'dart:async';

// Package imports.
import 'package:solid_auth/solid_auth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Project imports.
import 'package:podnotes/common/app.dart';


// Future<List> initialStructureTest(Map authData) async {
//   var rsaInfo = authData['rsaInfo'];
//   var rsaKeyPair = rsaInfo['rsa'];
//   var publicKeyJwk = rsaInfo['pubKeyJwk'];
//   String accessToken = authData['accessToken'];
//   Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

//   // Get webID
//   String webId = decodedToken['webid'];
//   bool allExists = true;
//   Map resNotExist = {
//     'folders': [],
//     'files': [],
//     'folderNames': [],
//     'fileNames': []
//   };

//   for (String containerName in FOLDERS) {
//     String resourceUrl = webId.replaceAll('profile/card#me', '$containerName/');
//     String dPopToken =
//         genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');
//     if (await checkResourceExistsNew(
//             resourceUrl, accessToken, dPopToken, false) ==
//         'not-exist') {
//       allExists = false;
//       String resourceUrlStr =
//           webId.replaceAll('profile/card#me', '$containerName');
//       resNotExist['folders'].add(resourceUrlStr);
//       resNotExist['folderNames'].add(containerName);
//     }
//   }

//   for (var containerName in FILES.keys) {
//     List fileNameList = FILES[containerName];
//     for (String fileName in fileNameList) {
//       String resourceUrl =
//           webId.replaceAll('profile/card#me', '$containerName/$fileName');
//       String dPopToken =
//           genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');
//       if (await checkResourceExistsNew(
//               resourceUrl, accessToken, dPopToken, false) ==
//           'not-exist') {
//         allExists = false;
//         resNotExist['files'].add(resourceUrl);
//         resNotExist['fileNames'].add(fileName);
//       }
//     }
//   }

//   return [allExists, resNotExist];
// }