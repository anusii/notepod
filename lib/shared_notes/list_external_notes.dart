/// A stateful widget to list external notes.
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://opensource.org/license/gpl-3-0
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

import 'package:flutter/material.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/models/external_note.dart';
import 'package:notepod/shared_notes/non_readable_note.dart';
import 'package:notepod/shared_notes/share_external_note.dart';
import 'package:notepod/shared_notes/title_external_note_screen.dart';
import 'package:notepod/shared_notes/view_shared_note_screen.dart';
import 'package:notepod/utils/nav_to_child.dart';
import 'package:notepod/widgets/simple_action_button.dart';

/// A [stateful] widget to list externally owned notes shared to the
/// user.
///
/// Arguments:
/// - [notes] - The externally owned notes shared to the user.

class ListExternalNotes extends StatefulWidget {
  final List<ExternalNote> notes;

  const ListExternalNotes({
    super.key,
    required this.notes,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ListExternalNotesState createState() => _ListExternalNotesState();
}

class _ListExternalNotesState extends State<ListExternalNotes> {
  /// Filtered map of notes.
  List<FoundExternalNote> _foundNotes = [];

  /// Initial sort by note filename order.
  bool _sortFilenameAscending = true;

  /// Initial sort by note owner order.
  bool _sortOwnerAscending = true;

  /// Initial sort by note owner order.
  bool _sortPermissionAscending = true;

  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Aspect ratio (width / height) for gridview
  /// cards to display note items
  late double cardAspectRatio = 2.0;

  /// Boolean describing whether window is narrow
  late bool isNarrow;

  /// Boolean describing whether note is external
  final bool isExternal = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // By default _foundNotes is the full list of notes
    _foundNotes = widget.notes.toListFoundExternalNote();

    // Initial sort by filename alphabetically
    _sortByFilename(_sortFilenameAscending);
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  /// Sort alphanumerically on note filename
  void _sortByFilename(bool ascending) {
    setState(() {
      _sortFilenameAscending = ascending;
      _foundNotes.sort(
        (a, b) => _sortFilenameAscending
            ? a.noteFileName
                .toLowerCase()
                .compareTo(b.noteFileName.toLowerCase())
            : b.noteFileName
                .toLowerCase()
                .compareTo(a.noteFileName.toLowerCase()),
      );
    });
  }

  /// Sort alphanumerically on note owner
  void _sortByOwner(bool ascending) {
    setState(() {
      _sortOwnerAscending = ascending;

      _foundNotes.sort(
        (a, b) => _sortOwnerAscending
            ? a.noteOwner.toLowerCase().compareTo(b.noteOwner.toLowerCase())
            : b.noteOwner.toLowerCase().compareTo(a.noteOwner.toLowerCase()),
      );
    });
  }

  /// Sort alphanumerically on note permissions
  void _sortByPermission(bool ascending) {
    setState(() {
      _sortPermissionAscending = ascending;

      _foundNotes.sort(
        (a, b) => _sortPermissionAscending
            ? a.permissionList
                .toLowerCase()
                .compareTo(b.permissionList.toLowerCase())
            : b.permissionList
                .toLowerCase()
                .compareTo(a.permissionList.toLowerCase()),
      );
    });
  }

  /// Search notes
  void _searchNotes(String enteredKeyword) {
    List<FoundExternalNote> results = [];
    if (enteredKeyword.isEmpty) {
      // Display all notes if no search string
      results = widget.notes.toListFoundExternalNote();
    } else {
      // Search for matches in filename, owner, permission granter or permission list
      results = widget.notes.toListFoundExternalNote().where((note) {
        return note.noteFileName
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            note.noteOwner
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            note.permissionGranter
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            note.permissionList
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase());
      }).toList();
    }

    // Refresh the UI
    setState(() {
      _foundNotes = results;

      // Sort results by filename
      _sortByFilename(_sortFilenameAscending);
    });
  }

  /// Return id part of a webId
  String getId(webId) {
    final Uri uri = Uri.parse(webId);
    final String id = uri.pathSegments.first;

    return id;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Derive whether window is narrow
        isNarrow = WindowSize().isNarrowWindow(constraints);
        // Calculate the aspect radio for grid cards
        cardAspectRatio =
            NoteItemSize().calculateCardAspectRatio(constraints, isExternal);
        return SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$sharedNotesTitle (created by other people)',
                      style: titleStyle,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (value) => _searchNotes(value),
                      decoration: const InputDecoration(
                        labelText:
                            'Search filename, owner, permission granter, permissions',
                        hintText: 'Enter string to match note metadata',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Count statement
                        // Match color scheme of sorting TextButtons
                        _foundNotes.length > 1 || _foundNotes.isEmpty
                            ? Text(
                                'Found ${_foundNotes.length} notes',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : Text(
                                'Found ${_foundNotes.length} note',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Filename Sort Label and Button
                            TextButton.icon(
                              onPressed: () {
                                _sortByFilename(!_sortFilenameAscending);
                              },
                              icon: Icon(
                                _sortFilenameAscending
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                              ),
                              label: Text(
                                _sortFilenameAscending
                                    ? !isNarrow
                                        ? 'Filename A to Z'
                                        : 'Filename'
                                    : !isNarrow
                                        ? 'Filename Z to A'
                                        : 'Filename',
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            // Owner Sort Label and Button
                            TextButton.icon(
                              onPressed: () {
                                _sortByOwner(!_sortOwnerAscending);
                              },
                              icon: Icon(
                                _sortOwnerAscending
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                              ),
                              label: Text(
                                _sortOwnerAscending
                                    ? !isNarrow
                                        ? 'Owner A to Z'
                                        : 'Owner'
                                    : !isNarrow
                                        ? 'Owner Z to A'
                                        : 'Owner',
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                            // Only display permissions sort
                            // when window is not narrow
                            if (!isNarrow) ...[
                              SizedBox(
                                width: 5.0,
                              ),
                              // Permission Sort Label and Button
                              TextButton.icon(
                                onPressed: () {
                                  _sortByPermission(!_sortPermissionAscending);
                                },
                                icon: Icon(
                                  _sortPermissionAscending
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                ),
                                label: Text(
                                  _sortPermissionAscending
                                      ? 'Permission A to Z'
                                      : 'Permission Z to A',
                                ),
                                iconAlignment: IconAlignment.end,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      // Aspect ratio calculated from LayoutBuilder box constraints
                      crossAxisCount: 1,
                      childAspectRatio: cardAspectRatio,
                    ),
                    padding: const EdgeInsets.all(10),
                    itemCount: _foundNotes.length,
                    itemBuilder: (context, index) => Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Center(
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.edit_document),
                          ),
                          // Define width to avoid consuming full width
                          title: TitleExternalNote(
                            note: _foundNotes[index],
                          ),
                          subtitle: Text(
                            'Filename: ${_foundNotes[index].noteFileName} \nOwner: ${getId(_foundNotes[index].noteOwner)} \nShared by: ${getId(_foundNotes[index].permissionGranter)} \nPermissions: ${_foundNotes[index].permissionList}',
                          ),

                          // Define width to avoid consuming full width
                          trailing: SizedBox(
                            height: 60,
                            width: 120,
                            child: SharedTrailingButtons(
                              note: _foundNotes[index],
                            ),
                          ),

                          onTap: () {
                            // Open note if read in permissions
                            // String access =
                            //     _foundNotes[sharedNotesUrlList[index]]
                            //         [permissionListPred];
                            String access = _foundNotes[index].permissionList;
                            if (access.contains('read')) {
                              navToChildPage(
                                context: context,
                                childPage: ViewSharedNoteScreen(
                                  note: _foundNotes[index],
                                ),
                              );
                            } else {
                              navToChildPage(
                                context: context,
                                childPage: NonReadableNote(
                                  note: _foundNotes[index],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TitleExternalNote extends StatelessWidget {
  final FoundExternalNote _note;

  const TitleExternalNote({
    super.key,
    required note,
  }) : _note = note;

  @override
  Widget build(BuildContext context) {
    List accessList = _note.permissionList.split(',');

    return Row(
      children: [
        if (accessList.contains('read')) ...[
          TitleExternalNoteScreen(
            note: _note,
          ),
        ] else ...[
          Text('Title access requires read permission'),
        ],
      ],
    );
  }
}

class SharedTrailingButtons extends StatelessWidget {
  const SharedTrailingButtons({
    super.key,
    required FoundExternalNote note,
  }) : _note = note;

  final FoundExternalNote _note;

  @override
  Widget build(BuildContext context) {
    List accessList = _note.permissionList.split(',');

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Share button if control in permissions
        if (accessList.contains('control')) ...[
          SimpleActionButton(
            icon: const Icon(Icons.share),
            childPage: ShareExternalNote(
              note: _note,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
        // Open note icon
        const Icon(Icons.arrow_forward),
      ],
    );
  }
}
