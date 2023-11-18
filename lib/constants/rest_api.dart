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

// import 'dart:async';

// import 'package:solid_auth/solid_auth.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';

// import 'package:podnotes/common/app.dart';

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
