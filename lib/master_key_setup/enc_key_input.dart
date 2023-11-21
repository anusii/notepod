/// Individual's PODs app for diabetes care in Yarrabah.
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
/// Authors: Anushka Vidanage, Graham Williams

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:podnotes/nav_screen.dart';
import 'package:podnotes/constants/app.dart';
import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/constants/crypto.dart';

class EncryptionKeyInput extends StatefulWidget {
  final ValueNotifier<bool?> validEncKey;
  final FlutterSecureStorage storage;
  final String webId;
  final Map authData;

  EncryptionKeyInput({
    Key? key,
    required this.validEncKey,
    required this.storage,
    required this.webId,
    required this.authData,
  }) : super(key: key);

  @override
  _EncryptionKeyInputState createState() => _EncryptionKeyInputState();
}

class _EncryptionKeyInputState extends State<EncryptionKeyInput> {
  bool _obscureText = true;
  TextEditingController _keyController = TextEditingController();

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.0),
        Text("Encryption Key",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        SizedBox(height: 20.0),
        ValueListenableBuilder<bool?>(
          valueListenable: widget.validEncKey,
          builder: (context, validKey, child) {
            if (validKey == null) {
              return Text('Please enter encryption key to encrypt your data.',
                  style: TextStyle(color: warningRed));
            } else if (validKey) {
              return Text(
                'Your encryption key is valid.',
                style: TextStyle(fontSize: 15, color: confirmGreen),
              );
            } else {
              return Text('Your encryption key is invalid.',
                  style: TextStyle(fontSize: 15, color: warningRed));
            }
          },
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  obscureText: _obscureText,
                  controller: _keyController,
                  decoration: InputDecoration(
                    hintText: widget.validEncKey.value == null
                        ? 'Please enter encryption key'
                        : 'Update encryption key',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: _toggle,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                ),
                onPressed: () async {
                  if (_keyController.text.isEmpty) {
                    return;
                  } else {
                    bool isKeyExist = await widget.storage.containsKey(
                      key: widget.webId,
                    );

                    // Since write() method does not automatically overwrite an existing value.
                    // To overwrite an existing value, call delete() first.

                    if (isKeyExist) {
                      await widget.storage.delete(
                        key: widget.webId,
                      );
                    }

                    await widget.storage.write(
                      key: widget.webId,
                      value: _keyController.text,
                    );

                    await secureStorage.write(
                      key: widget.webId,
                      value: _keyController.text,
                    );

                    String secureKey =
                        await widget.storage.read(key: widget.webId) ?? '';

                    // av:20231109 - following part is temporary code. Remove that
                    // after we figure out how to work with secure data storage without
                    // async
                    // String enc_key = sha256
                    //     .convert(
                    //       utf8.encode(
                    //         secureKey,
                    //       ),
                    //     )
                    //     .toString()
                    //     .substring(0, 32);

                    //APP_STORAGE.setItem('encKey', enc_key);
                    // Remove upto here

                    verifyEncKey(secureKey, widget.authData).then((value) {
                      widget.validEncKey.value =
                          value; // Update the ValueNotifier
                      if (value) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NavigationScreen(
                                    webId: widget.webId,
                                    authData: widget.authData,
                                    page: 'home',
                                  )),
                        );
                      } else {}
                    });
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Text("WebID",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText(widget.webId),
              ),
            ),
          ],
        ),

        // Spacer(),

        // // Only show version text in mobile version.

        // !Responsive.isDesktop(context)
        //     ? Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           SelectableText(
        //             APP_VERSION,
        //             style: TextStyle(
        //               fontSize: versionTextSize,
        //               color: Colors.black,
        //             ),
        //           ),
        //         ],
        //       )
        //     : Container(),

        // // Avoid the APP_VERSION disappear at the bottom.

        SizedBox(
          height: screenHeight(context) * 0.1,
        )
      ],
    );
  }
}
