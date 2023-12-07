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
/// Authors: Anushka Vidanage
library;

import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:podnotes/common/rest_api/res_permission.dart';
import 'package:podnotes/common/rest_api/rest_api.dart';
import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/constants/rdf_functions.dart';
import 'package:podnotes/nav_screen.dart';
import 'package:podnotes/notes/share_note.dart';

class ViewNote extends StatefulWidget {
  final Map noteData;
  final String webId;
  final Map authData;

  const ViewNote({
    super.key,
    required this.noteData,
    required this.webId,
    required this.authData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ViewNoteState createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  @override
  Widget build(BuildContext context) {
    Map noteData = widget.noteData;

    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 10, 5),
              child: Text(
                noteData['noteTitle'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 5, 10, 10),
              child: Text(
                'Created on: ' + noteData['createdDateTime'],
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SizedBox(
            child: Container(
                padding: const EdgeInsets.all(10),
                child: MarkdownParse(
                  data: noteData['noteContent'],
                  // onTapHastag: (String name, String match) {
                  //   // name => hashtag
                  //   // match => #hashtag
                  // },
                  // onTapMention: (String name, String match) {
                  //   // name => mention
                  //   // match => #mention
                  // },
                )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                onPressed: () async {
                  // Get the permission info of the note
                  Map filePermMap = await getPermission(
                    widget.authData,
                    noteData['noteFileName'],
                    noteData['noteFileUrl'],
                  );

                  Map resInfo = {};
                  resInfo['resName'] = noteData['noteFileName'];
                  resInfo['resType'] = 'File';
                  resInfo['resUrl'] = noteData['noteFileUrl'];

                  // The [userPerMap] is empty, which means the user have no access
                  // to the folder/file. In this case, the lock_open button will not work.

                  // if (filePermInfo.isEmpty) {
                  //   setState(() {
                  //     widget.isSharedFolderList[index] = false;
                  //   });

                  //   return;
                  // }

                  Map permNameMap = {};
                  for (var permWebId in filePermMap.keys) {
                    String permWebIdUrl = permWebId.replaceAll('<', '');
                    permWebIdUrl = permWebIdUrl.replaceAll('>', '');

                    String profInfo = await fetchPubFile(permWebIdUrl);
                    PodProfile podProfile = PodProfile(profInfo.toString());
                    String profName = podProfile.getProfName();
                    permNameMap[permWebId] = profName;
                  }

                  resInfo['resPerm'] = filePermMap;
                  resInfo['resUsername'] = permNameMap;

                  // ignore: use_build_context_synchronously
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShareNote(
                              webId: widget.webId,
                              authData: widget.authData,
                              resInfo: resInfo,
                            )),
                    (Route<dynamic> route) =>
                        false, // This predicate ensures all previous routes are removed
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: darkBlue,
                  backgroundColor: lightBlue, // foreground
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                label: const Text(
                  'SHARE',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavigationScreen(
                                webId: widget.webId,
                                authData: widget.authData,
                                page: 'editNote',
                                noteFileName: noteData['noteFileName'],
                              )),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: darkGreen,
                  backgroundColor: lightGreen, // foreground
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                label: const Text(
                  'EDIT',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.keyboard_backspace,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NavigationScreen(
                              webId: widget.webId,
                              authData: widget.authData,
                              page: 'listNotes',
                            )),
                    (Route<dynamic> route) =>
                        false, // This predicate ensures all previous routes are removed
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: titleAsh,
                  backgroundColor: lightGray, // foreground
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                label: const Text(
                  'GO BACK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
    // Column(
    //   children: [
    //     const SizedBox(height: 20.0),
    //     const Text("Encryption Key",
    //         style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
    //     const SizedBox(height: 20.0),

    //     const SizedBox(
    //       height: 10,
    //     ),
    //     const Text("WebID",
    //         style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
    //     const SizedBox(
    //       height: 10,
    //     ),

    //     // Spacer(),

    //     // // Only show version text in mobile version.

    //     // !Responsive.isDesktop(context)
    //     //     ? Row(
    //     //         mainAxisAlignment: MainAxisAlignment.end,
    //     //         children: [
    //     //           SelectableText(
    //     //             APP_VERSION,
    //     //             style: TextStyle(
    //     //               fontSize: versionTextSize,
    //     //               color: Colors.black,
    //     //             ),
    //     //           ),
    //     //         ],
    //     //       )
    //     //     : Container(),

    //     // // Avoid the APP_VERSION disappear at the bottom.

    //     SizedBox(
    //       height: screenHeight(context) * 0.1,
    //     )
    //   ],
    // );
  }
}
