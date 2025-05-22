/// Navigation Drawer for notepod.
///
/// Copyright (C) 2025, Software Innovation Institute
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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/utils/misc.dart';
import 'package:notepod/app_screen.dart';
import 'package:notepod/home.dart';
import 'package:notepod/main.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/shared_notes/shared_notes_screen.dart';

class NavDrawer extends StatelessWidget {
  final String webId;

  const NavDrawer({
    super.key,
    required this.webId,
  });

  @override
  Widget build(BuildContext context) {
    String name = '';
    if (webId.isNotEmpty) {
      name = getNameFromWebId(webId);
    } else {
      name = 'Not logged in';
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 24 + MediaQuery.of(context).padding.top,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: darkGreen,
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  name,
                  style: const TextStyle(color: backgroundWhite, fontSize: 25),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    webId,
                    style:
                        const TextStyle(color: backgroundWhite, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            child: Wrap(
              runSpacing: 10,
              children: [
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppScreen(
                          title: topBarTitle,
                          childPage: Home(),
                        ),
                      ),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_list),
                  title: const Text('My Notes'),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppScreen(
                          title: topBarTitle,
                          childPage: ListNotesScreen(),
                        ),
                      ),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.share_rounded),
                //   title: const Text('Note Sharing'),
                //   onTap: () => {Navigator.of(context).pop()},
                // ),
                ListTile(
                  leading: const Icon(Icons.file_open_outlined),
                  title: const Text('Shared Notes'),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppScreen(
                          title: topBarTitle,
                          childPage: SharedNotesScreen(),
                          // childPage: SharedNotes(),
                        ),
                      ),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                ),
                const Divider(
                  color: titleAsh,
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.lock_outline),
                //   title: const Text('Setup Encryption Key'),
                //   onTap: () {
                //     Navigator.pushAndRemoveUntil(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => NavigationScreen(
                //           webId: webId,
                //           authData: {'authData': ''},
                //           page: 'encKeyInput',
                //         ),
                //       ),
                //       (Route<dynamic> route) =>
                //           false, // This predicate ensures all previous routes are removed
                //     );
                //   },
                // ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Logout'),
                  onTap: webId.isEmpty
                      ? null
                      : () async {
                          // Then direct to logout popup
                          await logoutPopup(context, const NotePod());
                        },
                ),
                const Divider(
                  color: titleAsh,
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () => {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return _aboutDialog();
                      },
                    ),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Make About Dialog
Widget _aboutDialog() {
  return AboutDialog(
    applicationName: applicationName,
    applicationIcon: SizedBox(
      height: 65,
      width: 65,
      child: Image.asset('assets/images/notepod.png'),
    ),
    applicationVersion: applicationVersion,
    // applicationLegalese: "© Copyright Michelphoenix 2020",
    children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(
          text: TextSpan(
            text: 'An ',
            style: const TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: 'ANU Software Innovation Institute',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse(siiUrl));
                  },
              ),
              const TextSpan(
                text: ' demo project for Solid PODs.',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'For more information see the ',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: 'Notepod',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse(applicationRepo));
                  },
              ),
              const TextSpan(
                text: ' github repository.',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        const Text(authors),
      ]),
    ],
  );
}
