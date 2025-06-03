import 'package:flutter/material.dart';
import 'package:notepod/app_screen.dart';
import 'package:notepod/constants/app.dart';

import 'package:notepod/constants/colours.dart';
import 'package:notepod/shared_notes/edit_shared_note.dart';
import 'package:notepod/shared_notes/share_external_note.dart';

ElevatedButton shareNote(
    BuildContext context, Map<dynamic, dynamic> fullNoteData) {
  return ElevatedButton.icon(
    icon: const Icon(
      Icons.share,
      color: Colors.white,
    ),
    onPressed: () {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => AppScreen(
                  title: topBarTitle,
                  childPage: ShareExternalNote(
                    fullNoteData: fullNoteData,
                  ),
                  // childPage: SharedNotes(),
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

ElevatedButton editNote(
  BuildContext context,
  Map<dynamic, dynamic> fullNoteData,
) {
  return ElevatedButton.icon(
    icon: const Icon(
      Icons.edit,
      color: Colors.white,
    ),
    onPressed: () async {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => AppScreen(
                  childPage: EditSharedNote(
                    fullNoteData: fullNoteData,
                  ),
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
