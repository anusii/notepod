import 'package:flutter/material.dart';

import 'package:notepod/common/rest_api/res_permission.dart';
import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/rdf_functions.dart';
import 'package:notepod/nav_screen.dart';
import 'package:notepod/notes/share_note.dart';

ElevatedButton shareNote(Map<dynamic, dynamic> noteData, BuildContext context,
    Map authData, String webId) {
  return ElevatedButton.icon(
    icon: const Icon(
      Icons.share,
      color: Colors.white,
    ),
    onPressed: () async {
      // Get the permission info of the note
      Map filePermMap = await getPermission(
        authData,
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
                  webId: webId,
                  authData: authData,
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
  );
}

ElevatedButton editNote(BuildContext context, Map<dynamic, dynamic> noteData,
    Map authData, String webId) {
  return ElevatedButton.icon(
    icon: const Icon(
      Icons.edit,
      color: Colors.white,
    ),
    onPressed: () async {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => NavigationScreen(
                  webId: webId,
                  authData: authData,
                  page: 'editSharedNote',
                  sharedNoteData: noteData['noteMetadata'],
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
  );
}
