/// DESCRIPTION - PLEASE ADD A DESCRIPTION OF THIS FILE HERE ZHEYUAN.
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
/// Authors: WHO WROTE THIS ORIGINALLY? ZHEYUAN OR ANUSHKA?

library;

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fast_rsa/fast_rsa.dart' as frsa;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:solid_auth/solid_auth.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/crypto.dart';
import 'package:notepod/constants/file_structure.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/login/screen.dart';
import 'package:notepod/nav_screen.dart';
import 'package:notepod/utils/truncate_str.dart';
import 'package:notepod/widgets/err_dialogs.dart';
import 'package:notepod/widgets/loading_animation.dart';
import 'package:notepod/widgets/msg_box.dart';

class InitialSetupDesktop extends StatefulWidget {
  final Map resNeedToCreate;
  final Map authData;
  final String webId;
  const InitialSetupDesktop({
    super.key,
    required this.resNeedToCreate,
    required this.authData,
    required this.webId,
  });

  @override
  State<InitialSetupDesktop> createState() {
    return _InitialSetupDesktopState();
  }
}

class _InitialSetupDesktopState extends State<InitialSetupDesktop> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    List<String> genderOptions = ['Male', 'Female', 'Other'];

    void onChangedVal(dynamic val) => debugPrint(val.toString());
    bool showPassword = true;

    // print(widget.resNeedToCreate['folders']);

    return Column(
      children: [
        Expanded(
          child: SizedBox(
            height: 700,
            child: ListView(primary: false, children: [
              Center(
                child: SizedBox(
                  //height: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: lightGreen,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.playlist_add,
                            color: Colors.white,
                            size: 50,
                          ),
                        ), //CircleAvatar
                        const SizedBox(
                          height: 10,
                        ), //SizedBox
                        const Text(
                          initialStructureWelcome,
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ), //Textstyle
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: buildMsgBox(context, 'warning',
                              initialStructureTitle, initialStructureMsg),
                        ),
                      ],
                    ), //Column
                  ), //Padding
                ),
              ),
              Center(
                child: SizedBox(
                  //height: 500,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(80, 10, 80, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resources that will be created!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                        ),
                        for (String resLink
                            in widget.resNeedToCreate['folders']) ...[
                          ListTile(
                            title: Text(resLink),
                            leading: const Icon(Icons.folder),
                          ),
                        ],
                        const SizedBox(
                          height: 20,
                        ),
                        for (String resLink
                            in widget.resNeedToCreate['files']) ...[
                          ListTile(
                            title: Text(resLink),
                            leading: const Icon(Icons.file_copy),
                          ),
                        ],
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  //height: 500,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(80, 10, 80, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          //[

                          <Widget>[
                        FormBuilder(
                          key: formKey,
                          // enabled: false,
                          onChanged: () {
                            formKey.currentState!.save();
                            debugPrint(
                              formKey.currentState!.value.toString(),
                            );
                          },
                          autovalidateMode: AutovalidateMode.disabled,
                          initialValue: const {
                            //'movie_rating': 5,
                            //'best_language': 'Dart',
                            //'age': '13',
                            //'gender': 'Male',
                            //'languages_filter': ['Dart']
                          },
                          skipDisabled: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Please fill-up the following form (all fields are required)',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Divider(
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'PERSONAL',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              FormBuilderTextField(
                                name: 'name',
                                decoration: const InputDecoration(
                                  labelText: 'NAME',
                                  labelStyle: TextStyle(
                                    color: darkBlue,
                                    letterSpacing: 1.5,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  //errorText: 'error',
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                ]),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              FormBuilderDropdown<String>(
                                name: 'gender',
                                decoration: InputDecoration(
                                  labelText: 'GENDER',
                                  labelStyle: const TextStyle(
                                    color: darkBlue,
                                    letterSpacing: 1.5,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  suffix: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      formKey.currentState!.fields['gender']
                                          ?.reset();
                                    },
                                  ),
                                  hintText: 'Select Gender',
                                ),
                                items: genderOptions
                                    .map((gender) => DropdownMenuItem(
                                          alignment:
                                              AlignmentDirectional.center,
                                          value: gender,
                                          child: Text(gender),
                                        ))
                                    .toList(),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                ]),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                requiredPwdMsg,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              FormBuilderTextField(
                                name: 'password',
                                obscureText: showPassword,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  labelText: 'PASSWORD',
                                  labelStyle: TextStyle(
                                    color: darkBlue,
                                    letterSpacing: 1.5,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  //errorText: 'error',
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                ]),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              FormBuilderTextField(
                                name: 'repassword',
                                obscureText: showPassword,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  labelText: 'RETYPE PASSWORD',
                                  labelStyle: TextStyle(
                                    color: darkBlue,
                                    letterSpacing: 1.5,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  //errorText: 'error',
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  (val) {
                                    if (val !=
                                        formKey.currentState!.fields['password']
                                            ?.value) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ]),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                publicKeyMsg,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              FormBuilderCheckbox(
                                name: 'providepermission',
                                initialValue: false,
                                onChanged: onChangedVal,
                                title: RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            'Please confirm that you agree to provide permission to create all the above resources! ',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      //                   TextSpan(
                                      //                     text: 'Terms and Conditions',
                                      //                     style: TextStyle(
                                      //                         color: Colors.blue),
                                      //                     // Flutter doesn't allow a button inside a button
                                      //                     // https://github.com/flutter/flutter/issues/31437#issuecomment-492411086
                                      //                     /*
                                      // recognizer: TapGestureRecognizer()
                                      //   ..onTap = () {
                                      //     print('launch url');
                                      //   },
                                      // */
                                      //                   ),
                                    ],
                                  ),
                                ),
                                validator: FormBuilderValidators.equal(
                                  true,
                                  errorText:
                                      'You must provide permission to continue',
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState?.saveAndValidate() ??
                                      false) {
                                    showAnimationDialog(
                                      context,
                                      17,
                                      'Creating resources!',
                                      false,
                                    );
                                    Map formData =
                                        formKey.currentState?.value as Map;

                                    String passPlaintxt = formData['password'];

                                    // variable to see whether we need to update
                                    // the key files. Because if one file is missing
                                    // we need to create asymmetric key pairs again

                                    // Verify encryption master key if it is already
                                    // in the file
                                    bool keyVerifyFlag = true;

                                    // Enryption master key
                                    String? encMasterKeyVerify;
                                    String? encMasterKey;

                                    // Asymmetric key pair
                                    String? pubKey;
                                    String? pubKeyStr;
                                    String? prvKey;
                                    String? prvKeyHash;
                                    String? prvKeyIvz;

                                    // Create files and directories flag
                                    bool createFileSuccess = true;
                                    bool createDirSuccess = true;

                                    if (widget.resNeedToCreate['fileNames']
                                            .contains(encKeyFile) ||
                                        widget.resNeedToCreate['fileNames']
                                            .contains(pubKeyFile)) {
                                      // Generate master key
                                      encMasterKey = sha256
                                          .convert(utf8.encode(passPlaintxt))
                                          .toString()
                                          .substring(0, 32);
                                      encMasterKeyVerify = sha224
                                          .convert(utf8.encode(passPlaintxt))
                                          .toString()
                                          .substring(0, 32);

                                      // Generate asymmetric key pair
                                      var rsaKeyPair =
                                          await frsa.RSA.generate(2048);
                                      prvKey = rsaKeyPair.privateKey;
                                      pubKey = rsaKeyPair.publicKey;

                                      // Encrypt private key
                                      final key =
                                          encrypt.Key.fromUtf8(encMasterKey);
                                      final iv = encrypt.IV.fromLength(16);
                                      final encrypter = encrypt.Encrypter(
                                        encrypt.AES(
                                          key,
                                          mode: encrypt.AESMode.cbc,
                                        ),
                                      );
                                      final encryptVal =
                                          encrypter.encrypt(prvKey, iv: iv);
                                      prvKeyHash = encryptVal.base64.toString();
                                      prvKeyIvz = iv.base64.toString();

                                      // Get public key without start and end bit
                                      pubKeyStr = dividePubKeyStr(pubKey);

                                      if (!widget.resNeedToCreate['fileNames']
                                          .contains(encKeyFile)) {
                                        EncryptClient encryptClient =
                                            EncryptClient(
                                                widget.authData, widget.webId);
                                        keyVerifyFlag = await encryptClient
                                            .verifyEncKey(passPlaintxt);
                                      }
                                    }

                                    if (!keyVerifyFlag) {
                                      // ignore: use_build_context_synchronously
                                      showErrDialog(
                                        context,
                                        'Wrong encode key. Please try again!',
                                      );
                                    } else {
                                      // Create folders
                                      for (String resLink in widget
                                          .resNeedToCreate['folders']) {
                                        String serverUrl = widget.webId
                                            .replaceAll(profCard, '');
                                        String resNameStr =
                                            resLink.replaceAll(serverUrl, '');
                                        String resName =
                                            resNameStr.split('/').last;

                                        // Get resource path
                                        String folderPath =
                                            resNameStr.replaceAll(resName, '');

                                        String createDirRes = await createItem(
                                          false,
                                          resName,
                                          '',
                                          widget.webId,
                                          widget.authData,
                                          fileLoc: folderPath,
                                        );

                                        if (createDirRes != 'ok') {
                                          createDirSuccess = false;
                                        }
                                      }

                                      // Create files
                                      for (String resLink
                                          in widget.resNeedToCreate['files']) {
                                        // Get base url
                                        String serverUrl = widget.webId
                                            .replaceAll(profCard, '');

                                        // Get resource path and name
                                        String resNameStr =
                                            resLink.replaceAll(serverUrl, '');

                                        // Get resource name
                                        String resName =
                                            resNameStr.split('/').last;

                                        // Get resource path
                                        String filePath =
                                            resNameStr.replaceAll(resName, '');

                                        String fileBody = '';

                                        if (resName == encKeyFile) {
                                          fileBody = genEncKeyBody(
                                            encMasterKeyVerify!,
                                            prvKeyHash!,
                                            prvKeyIvz!,
                                            resLink,
                                          );
                                        } else if ([
                                          '$pubKeyFile.acl',
                                          '$permLogFile.acl'
                                        ].contains(resName)) {
                                          if (resName == '$permLogFile.acl') {
                                            fileBody = genLogAclBody(
                                                widget.webId,
                                                resName.replaceAll('.acl', ''));
                                          } else {
                                            fileBody =
                                                genPubFileAclBody(resName);
                                          }
                                        } else if (resName == '.acl') {
                                          fileBody = genPubDirAclBody();
                                        } else if (resName == indKeyFile) {
                                          fileBody = genIndKeyFileBody();
                                        } else if (resName == pubKeyFile) {
                                          fileBody = genPubKeyFileBody(
                                              resLink, pubKeyStr!);
                                        } else if (resName == permLogFile) {
                                          fileBody = genLogFileBody();
                                        }

                                        bool aclFlag = false;
                                        if (resName.split('.').last == 'acl') {
                                          aclFlag = true;
                                        }

                                        String createFileRes = await createItem(
                                            true,
                                            resName,
                                            fileBody,
                                            widget.webId,
                                            widget.authData,
                                            fileLoc: filePath,
                                            fileType: fileType[
                                                resName.split('.').last],
                                            aclFlag: aclFlag);

                                        if (createFileRes != 'ok') {
                                          createFileSuccess = false;
                                        }
                                      }
                                    }

                                    // Update the profile with new information
                                    String profBody = genProfFileBody(
                                        formData, widget.authData);
                                    String updateRes =
                                        await initialProfileUpdate(profBody,
                                            widget.authData, widget.webId);

                                    if (createFileSuccess &&
                                        createDirSuccess &&
                                        updateRes == 'ok') {
                                      imageCache.clear();
                                      // Add name to the authData
                                      widget.authData['name'] =
                                          formData['name'];

                                      // Add encryption key to the local secure storage
                                      bool isKeyExist =
                                          await secureStorage.containsKey(
                                        key: widget.webId,
                                      );

                                      // Since write() method does not automatically overwrite an existing value.
                                      // To overwrite an existing value, call delete() first.
                                      if (isKeyExist) {
                                        await secureStorage.delete(
                                          key: widget.webId,
                                        );
                                      }

                                      await secureStorage.write(
                                        key: widget.webId,
                                        value: passPlaintxt,
                                      );

                                      widget.authData['keyExist'] = true;
                                      // ignore: use_build_context_synchronously
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NavigationScreen(
                                                  webId: widget.webId,
                                                  authData: widget.authData,
                                                  page: 'home',
                                                )),
                                        (Route<dynamic> route) =>
                                            false, // This predicate ensures all previous routes are removed
                                      );
                                    }
                                  } else {
                                    showErrDialog(context,
                                        'Form validation failed! Please check your inputs.');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: darkBlue,
                                    backgroundColor: darkBlue, // foreground
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                child: const Text(
                                  'SUBMIT',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  formKey.currentState?.reset();
                                },
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: darkBlue,
                                    backgroundColor: darkBlue, // foreground
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                // color: Theme.of(context).colorScheme.secondary,
                                child: const Text(
                                  'RESET',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                      ],

                      // Text(
                      //   'Please fill-up the following form',
                      //   style: TextStyle(
                      //     color: Colors.black,
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      // Divider(
                      //   color: Colors.grey,
                      // ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // // createInputField(
                      // //     "NAME", nameController, ''),
                      // // createInputDateField(context,
                      // //     "DATE OF BIRTH", dobController, ''),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.black,
                    size: 24.0,
                  ),
                  label: const Text(
                    'LOGOUT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () async {
                    // APP_STORAGE.deleteItem('encKey');
                    await logout(widget.authData['logoutUrl']);
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Row buildInfoRow(String profName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          profName,
          style: TextStyle(
            color: Colors.grey[800],
            letterSpacing: 2.0,
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Column buildLabelRow(
      String labelName, String profName, BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '$labelName: ',
              style: TextStyle(
                color: kTitleTextColor,
                letterSpacing: 2.0,
                fontSize: screenWidth(context) * 0.015,
                fontWeight: FontWeight.bold,
                //fontFamily: 'Poppins',
              ),
            ),
            profName.length > longStrLength
                ? Tooltip(
                    message: profName,
                    height: 30,
                    textStyle:
                        const TextStyle(fontSize: 15, color: Colors.white),
                    verticalOffset: kDefaultPadding / 2,
                    child: Text(
                      truncateString(profName),
                      style: TextStyle(
                        color: Colors.grey[800],
                        letterSpacing: 2.0,
                        fontSize: screenWidth(context) * 0.015,
                        //fontFamily: 'Poppins',
                      ),
                    ),
                  )
                : Text(
                    profName,
                    style: TextStyle(
                        color: Colors.grey[800],
                        letterSpacing: 2.0,
                        fontSize: screenWidth(context) * 0.015),
                  ),
          ],
        ),
        SizedBox(
          height: screenHeight(context) * 0.005,
        )
      ],
    );
  }

  String capitalisedFirst(String text) {
    String result = '';
    if (text.length == 1) {
      result = text.toUpperCase();
    } else if (text.length > 1) {
      result = text[0].toUpperCase() + text.substring(1);
    }

    return result;
  }
}
