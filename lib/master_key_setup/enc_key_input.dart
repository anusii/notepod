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
library;

import 'package:flutter/material.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/crypto.dart';
import 'package:notepod/nav_screen.dart';
import 'package:notepod/widgets/err_dialogs.dart';

class EncryptionKeyInput extends StatefulWidget {
  final ValueNotifier<bool?> validEncKey;
  final String webId;
  final Map authData;

  const EncryptionKeyInput({
    super.key,
    required this.validEncKey,
    required this.webId,
    required this.authData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EncryptionKeyInputState createState() => _EncryptionKeyInputState();
}

class _EncryptionKeyInputState extends State<EncryptionKeyInput> {
  bool _obscureText = true;
  final TextEditingController _keyController = TextEditingController();

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20.0),
        const Text('Encryption Key',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20.0),
        ValueListenableBuilder<bool?>(
          valueListenable: widget.validEncKey,
          builder: (context, validKey, child) {
            if (validKey == null) {
              return const Text(encKeyInputMsg,
                  style: TextStyle(color: warningRed));
            } else if (validKey) {
              return const Text(
                encKeySuccess,
                style: TextStyle(fontSize: 15, color: confirmGreen),
              );
            } else {
              return const Text(encKeyInputMsg,
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
                        ? encKeyInputMsg
                        : encKeyUpdate,
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
                    bool isKeyExist = await secureStorage.containsKey(
                      key: widget.webId,
                    );

                    // Since write() method does not automatically overwrite an existing value.
                    // To overwrite an existing value, call delete() first.

                    String secureKey = _keyController.text;
                    bool keyCheck =
                        await verifyEncKey(secureKey, widget.authData);

                    if (keyCheck) {
                      if (isKeyExist) {
                        await secureStorage.delete(
                          key: widget.webId,
                        );
                      }

                      await secureStorage.write(
                        key: widget.webId,
                        value: secureKey,
                      );

                      widget.authData['keyExist'] = true;

                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NavigationScreen(
                                  webId: widget.webId,
                                  authData: widget.authData,
                                  page: 'home',
                                )),
                      );
                    } else {
                      // ignore: use_build_context_synchronously
                      showErrDialog(
                          context, 'Wrong encode key. Please try again!');
                    }
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
        const Text('WebID',
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
