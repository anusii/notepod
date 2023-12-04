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
import 'package:podnotes/nav_screen.dart';

class ListNotes extends StatefulWidget {
  final List fileList;
  final String webId;
  final Map authData;

  const ListNotes({
    super.key,
    required this.fileList,
    required this.webId,
    required this.authData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ListNotesState createState() => _ListNotesState();
}

class _ListNotesState extends State<ListNotes> {
  @override
  Widget build(BuildContext context) {
    List fileList = widget.fileList;
    return SizedBox(
      child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: fileList.length,
          itemBuilder: (context, index) => Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: ListTile(
                  leading: const CircleAvatar(
                    radius: 26,
                    backgroundImage: AssetImage('assets/images/note-icon.png'),
                  ),
                  //const Icon(Icons.text_snippet_outlined),
                  title: Text(fileList[index][0]),
                  subtitle: Text('Created on: ' + fileList[index][1]),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavigationScreen(
                                webId: widget.webId,
                                authData: widget.authData,
                                page: 'viewNote',
                                noteFileName: fileList[index][2],
                              )),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                ),
              )),
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
