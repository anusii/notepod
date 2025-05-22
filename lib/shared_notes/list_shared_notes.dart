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
import 'package:notepod/app_screen.dart';

import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/shared_notes/view_shared_note_screen.dart';

class ListSharedNotes extends StatefulWidget {
  final Map sharedNotesMap;

  const ListSharedNotes({
    super.key,
    required this.sharedNotesMap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ListSharedNotesState createState() => _ListSharedNotesState();
}

class _ListSharedNotesState extends State<ListSharedNotes> {
  @override
  Widget build(BuildContext context) {
    Map sharedNotesMap = widget.sharedNotesMap;
    List sharedNotesUrlList = sharedNotesMap.keys.toList();
    return SizedBox(
      child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: sharedNotesMap.length,
          itemBuilder: (context, index) => Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: ListTile(
                  leading: const CircleAvatar(
                    radius: 26,
                    backgroundImage: AssetImage('assets/images/note-icon.png'),
                  ),
                  //const Icon(Icons.text_snippet_outlined),
                  title: Text(
                      sharedNotesMap[sharedNotesUrlList[index]][noteFileName]),
                  subtitle: Text(
                      'Shared by: ${sharedNotesMap[sharedNotesUrlList[index]][noteOwner]} \nPermissions: ${sharedNotesMap[sharedNotesUrlList[index]][permissionList]}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    String notePermission =
                        sharedNotesMap[sharedNotesUrlList[index]]
                            [permissionList];
                    if (notePermission.contains('read')) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AppScreen(
                                  childPage: ViewSharedNoteScreen(
                                    sharedNoteData: sharedNotesMap[
                                        sharedNotesUrlList[index]],
                                  ),
                                )),
                        (Route<dynamic> route) =>
                            false, // This predicate ensures all previous routes are removed
                      );
                    } else {
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => NavigationScreen(
                      //             webId: widget.webId,
                      //             authData: widget.authData,
                      //             page: 'nonReadNote',
                      //             sharedNoteData: sharedNotesList[index],
                      //           )),
                      //   (Route<dynamic> route) =>
                      //       false, // This predicate ensures all previous routes are removed
                      // );
                    }
                  },
                ),
              )),
    );
  }
}
