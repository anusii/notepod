/// App login screen for connection to user's POD
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
/// Authors: Anushka Vidanage, Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:solid_auth/solid_auth.dart';

import 'package:podnotes/common/rest_api/rest_api.dart';
import 'package:podnotes/constants/app.dart';
import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/constants/rdf_functions.dart';
import 'package:podnotes/initial_setup/screen.dart';
import 'package:podnotes/login/pod_reg.dart';
import 'package:podnotes/nav_screen.dart';
import 'package:podnotes/widgets/loading_animation.dart';

/// A widget to display the initial login screen.
///
/// The login screen will be the intiial screen of the app when access to the
/// user's POD is required for any of the functionality of the app requires
/// access to the user's POD.

const _defaultWebID = 'https://pods.solidcommunity.au';
const _mainImage = AssetImage('assets/images/podnotes-background.jpg');

class LoginScreen extends StatelessWidget {
  // Show a default solid server for authorisation.

  final webIdController = TextEditingController()..text = _defaultWebID;

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      decoration: screenWidth(context) < 1175
          ? const BoxDecoration(
              image: DecorationImage(image: _mainImage, fit: BoxFit.cover))
          : null,
      child: Row(
        children: [
          screenWidth(context) < 1175
              ? Container()
              : Expanded(
                  flex: 7,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: _mainImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
          Expanded(
              flex: 5,
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: screenWidth(context) < 1175
                        ? screenWidth(context) < 750
                            ? screenWidth(context) * 0.05
                            : screenWidth(context) * 0.25
                        : screenWidth(context) * 0.05),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 5,
                    color: bgOffWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      height: 650,
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/podnotes.png',
                            width: 300,
                          ),
                          const SizedBox(
                            height: 0.0,
                          ),
                          const Divider(height: 15, thickness: 2),
                          const SizedBox(
                            height: 60.0,
                          ),
                          const Text('LOGIN WITH YOUR POD',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black,
                              )),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: webIdController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          createSolidLoginRow(context, webIdController),
                          const SizedBox(
                            height: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    )));
  }

  // Create login row for SOLID POD issuer

  Row createSolidLoginRow(
      BuildContext context, TextEditingController webIdTextController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(20),
            backgroundColor: lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async => launchIssuerReg(
              (await getIssuer(webIdTextController.text)).toString()),
          child: const Text(
            'GET A POD',
            style: TextStyle(
              color: titleAsh,
              letterSpacing: 2.0,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )),
        const SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(20),
              backgroundColor: lightGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              showAnimationDialog(
                context,
                7,
                'Logging in...',
                false,
              );

              // Get issuer URI.

              String issuerUri = await getIssuer(webIdTextController.text);

              // Define scopes. Also possible scopes -> webid, email, api.

              final List<String> scopes = <String>[
                'openid',
                'profile',
                'offline_access',
              ];

              // Authentication process for the POD issuer.

              var authData =
                  await authenticate(Uri.parse(issuerUri), scopes, context);

              // Decode access token to get the correct webId.

              String accessToken = authData['accessToken'];
              Map<String, dynamic> decodedToken =
                  JwtDecoder.decode(accessToken);
              String webId = decodedToken['webid'];

              // Perform check to see whether all required resources exists.

              List resCheckList = await initialStructureTest(authData);
              bool allExists = resCheckList.first;

              if (allExists) {
                imageCache.clear();

                // Get profile information.

                var rsaInfo = authData['rsaInfo'];
                var rsaKeyPair = rsaInfo['rsa'];
                var publicKeyJwk = rsaInfo['pubKeyJwk'];
                String accessToken = authData['accessToken'];
                String profCardUrl = webId.replaceAll('#me', '');
                String dPopToken =
                    genDpopToken(profCardUrl, rsaKeyPair, publicKeyJwk, 'GET');

                String profData =
                    await fetchPrvFile(profCardUrl, accessToken, dPopToken);

                Map profInfo = getFileContent(profData);
                authData['name'] = profInfo['fn'][1];

                // Check if master key is set in the local storage.

                bool isKeyExist = await secureStorage.containsKey(
                  key: webId,
                );
                authData['keyExist'] = isKeyExist;

                // Navigate to the profile through main screen.

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NavigationScreen(
                            webId: webId,
                            authData: authData,
                            page: 'home',
                          )),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InitialSetupScreen(
                            authData: authData,
                            webId: webId,
                          )),
                );
              }
            },
            child: const Text(
              'LOGIN',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 2.0,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
