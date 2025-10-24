/// Navigation Drawer for notepod.
///
/// Copyright (C) 2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Anushka Vidanage, Jess Moore
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:solidui/solidui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version_widget/version_widget.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/notepod.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/new_note.dart';
import 'package:notepod/shared_notes/list_external_notes_screen.dart';
import 'package:notepod/utils/misc.dart';
import 'package:notepod/utils/nav_to_child.dart';

class NavDrawer extends StatelessWidget {
  final String webId;
  final String appVersion;

  const NavDrawer({super.key, required this.webId, required this.appVersion});

  @override
  Widget build(BuildContext context) {
    String name = '';
    if (webId.isNotEmpty) {
      name = getNameFromWebId(webId);
    } else {
      name = 'Not logged in';
    }

    String url = '';
    if (webId.isNotEmpty) {
      Uri uri = Uri.parse(webId);
      url = '${uri.scheme}://${uri.host}';
    }

    return Drawer(
      shape: const Border(),
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
                    url,
                    style:
                        const TextStyle(color: backgroundWhite, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: VersionWidget(
                    version: appVersion,
                    changelogUrl:
                        // Currently (VersionWidget version 1.0.3) for the chrome/web
                        // deployment the first URL below results in CORS blocking while
                        // the second works. However the second renders raw text when
                        // tapped while the first renders the Markdown which is a whole
                        // lot nicer. So with the first on chrome/web the version
                        // checking does not work. (20250717 gjw)
                        'https://github.com/anusii/notepod/blob/dev/CHANGELOG.md',
                    // 'https://raw.githubusercontent.com/anusii/notepod/dev/CHANGELOG.md',
                    showDate: true,
                    // User specified text style - see branch on version_widget package
                    // fontSize: 12.0,
                    userTextStyle: const TextStyle(
                      color: backgroundWhite,
                      fontSize: 12,
                    ),
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
                  leading: const Icon(Icons.note_add_outlined),
                  title: const Text('New Note'),
                  onTap: () {
                    navToChildPage(
                      context: context,
                      childPage: const NewNote(),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_list),
                  title: const Text('My Notes'),
                  onTap: () {
                    navToChildPage(
                      context: context,
                      childPage: const ListNotesScreen(),
                    );
                  },
                ),
                ListTile(
                  // 20250717 jm: Alternate icons for Shared Notes
                  // leading: const Icon(Icons.share_rounded),
                  // leading: const Icon(Icons.file_open_outlined),
                  leading: const Icon(Icons.groups),
                  title: const Text(sharedNotesTitle),
                  onTap: () {
                    navToChildPage(
                      context: context,
                      childPage: const ListExternalNotesScreen(),
                    );
                  },
                ),
                const Divider(),
                // ListTile(
                //   leading: const Icon(Icons.settings),
                //   title: const Text('Settings'),
                //   onTap: () {
                //     Navigator.of(context).pop();
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
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () async {
                    // Get application getails
                    PackageInfo packageInfo = await PackageInfo.fromPlatform();
                    String appName = packageInfo.appName;
                    String version = packageInfo.version;

                    if (context.mounted) {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _aboutDialog(appName, version, context);
                        },
                      );
                    }
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
Widget _aboutDialog(String appName, String appVersion, BuildContext context) {
  // Reduce calls to of(context).
  final theme = Theme.of(context);

  return AboutDialog(
    applicationName: capitalize(appName),
    applicationIcon: SizedBox(
      height: 65,
      width: 65,
      child: Image.asset('assets/images/notepod.png'),
    ),
    applicationVersion: appVersion,
    // applicationLegalese: "© Copyright Michelphoenix 2020",
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'An '),
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
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(
                  text: 'For more information see the ',
                ),
                TextSpan(
                  text: capitalize(appName),
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(applicationRepo));
                    },
                ),
                const TextSpan(
                  text: ' github repository.',
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          const Text(authors),
        ],
      ),
    ],
  );
}
