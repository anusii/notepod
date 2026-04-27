/// A stateful widget to list notes.
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

import 'package:solidui/solidui.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/constants/ui.dart';
import 'package:notepod/models/note.dart';
import 'package:notepod/models/selected_note.dart';
import 'package:notepod/notes/list_notes_screen.dart';
import 'package:notepod/notes/non_readable_note.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/widgets/note_item_subtitle.dart';
import 'package:notepod/widgets/note_item_trailing_buttons.dart';
import 'package:notepod/widgets/note_list_del_button.dart';

/// A [stateful] widget to list notes accessible to the
/// user.
///
/// Arguments:
/// - [notes] - The notes accessible to the user.
/// - [title] - List title.
/// - [scaffoldController] - Controller for the Solid scaffold.

class ListNotes extends StatefulWidget {
  final List<Note> notes;
  final String title;
  final SolidScaffoldController scaffoldController;

  const ListNotes({
    super.key,
    required this.notes,
    required this.title,
    required this.scaffoldController,
  });

  @override
  State<ListNotes> createState() => _ListNotesState();
}

class _ListNotesState extends State<ListNotes> {
  /// Filtered map of notes.
  List<Note> _foundNotes = [];

  /// Selected notes
  final List<SelectedNote> selectedNotes = [];

  /// Sort title order
  /// true: ascending (A-Z), false: descending (Z-A)
  /// Initial sort will sort alphabetically
  bool _sortTitleAscending = true;

  /// Sort last modified date order
  /// true: ascending (oldest modified note), false: descending (last modified note)
  /// First button press will change to sort by last modified first
  bool _sortModDateAscending = true;

  /// Initial sort by note filename order.
  bool _sortFilenameAscending = true;

  // /// Initial sort by note owner order.
  // bool _sortOwnerAscending = true;

  // /// Initial sort by note owner order.
  // bool _sortPermissionAscending = true;

  /// Note selection mode
  /// true: when one or more notes have been selected, false by default
  bool _isSelectionMode = false;

  /// Count of selected notes
  int selectedCount = 0;

  /// Whether selection includes external files
  /// true: when one or more external notes have been selected, false by default
  bool _isExtFileSelected = false;

  /// Count of selected external notes
  int extSelectedCount = 0;

  /// Current note sort method
  /// Initialised to sort by title
  String currSortMethod = '';

  /// Scroll controller for single child scroll view
  late final ScrollController _scrollController;

  /// Scaffold controller
  late final SolidScaffoldController _scaffoldController;

  /// Aspect ratio (width / height) for gridview
  /// cards to display note items
  late double cardAspectRatio = 2.0;

  /// Screen width category flags derived from SolidScaffoldHelpers.
  late bool isVeryNarrow;
  late bool isNarrow;
  late bool isWide;
  late bool isVeryWide;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scaffoldController = widget.scaffoldController;

    // By default _foundNotes is the full list of notes
    _foundNotes = widget.notes;

    // Initial sort by title alphabetically
    _sortByTitle(_sortTitleAscending);

    // Initialise sorting method
    currSortMethod = 'sortByTitle';
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  // Sort alphanumerically on note title field, with null values last
  void _sortByTitle(bool ascending) {
    setState(() {
      _sortTitleAscending = ascending;
      _foundNotes.sort((a, b) {
        if (a.content == null && b.content == null) return 0;
        if (a.content == null) return 1;
        if (b.content == null) return -1;
        return _sortTitleAscending
            ? a.content!.noteTitle
                .toLowerCase()
                .compareTo(b.content!.noteTitle.toLowerCase())
            : b.content!.noteTitle
                .toLowerCase()
                .compareTo(a.content!.noteTitle.toLowerCase());
      });

      // Update current sort method
      currSortMethod = 'sortByTitle';
    });
  }

  // Sort numerically on note modified date field, with null values last
  void _sortByModDate(bool ascending) {
    setState(() {
      _sortModDateAscending = ascending;
      _foundNotes.sort((a, b) {
        if (a.content == null && b.content == null) return 0;
        if (a.content == null) return 1;
        if (b.content == null) return -1;
        return _sortModDateAscending
            ? a.content!.modifiedDateTime
                .toLowerCase()
                .compareTo(b.content!.modifiedDateTime.toLowerCase())
            : b.content!.modifiedDateTime
                .toLowerCase()
                .compareTo(a.content!.modifiedDateTime.toLowerCase());
      });

      // Update current sort method
      currSortMethod = 'sortByModDate';
    });
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

      // Update current sort method
      currSortMethod = 'sortByFilename';
    });
  }

  // TODO: allow owner sorting if isWide after isWide added to Solidui
  // /// Sort alphanumerically on note owner
  // void _sortByOwner(bool ascending) {
  //   setState(() {
  //     _sortOwnerAscending = ascending;

  //     _foundNotes.sort(
  //       (a, b) => _sortOwnerAscending
  //           ? a.noteOwner.toLowerCase().compareTo(b.noteOwner.toLowerCase())
  //           : b.noteOwner.toLowerCase().compareTo(a.noteOwner.toLowerCase()),
  //     );

  //     // Update current sort method
  //     currSortMethod = 'sortByOwner';
  //   });
  // }

  // TODO: allow permission sorting if isWide after isWide added to Solidui
  // /// Sort alphanumerically on note permissions
  // void _sortByPermission(bool ascending) {
  //   setState(() {
  //     _sortPermissionAscending = ascending;

  //     _foundNotes.sort(
  //       (a, b) => _sortPermissionAscending
  //           ? a.permissionList
  //               .toLowerCase()
  //               .compareTo(b.permissionList.toLowerCase())
  //           : b.permissionList
  //               .toLowerCase()
  //               .compareTo(a.permissionList.toLowerCase()),
  //     );

  //     // Update current sort method
  //     currSortMethod = 'sortByPermission';
  //   });
  // }

  /// Search notes
  void _searchNotes(String enteredKeyword) {
    List<Note> results = [];
    if (enteredKeyword.isEmpty) {
      // Display all notes if no search string
      results = widget.notes;
    } else {
      // Search for matches in filename, owner, permission granter or permission list
      results = widget.notes.where((note) {
        return (note.content?.noteTitle ?? 'unknown')
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            (note.content?.noteContent ?? 'unknown')
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            note.noteFileName
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            note.noteOwner
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()) ||
            (note.permissionGranter ?? 'n/a')
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

      // // Sort results by filename
      // _sortByFilename(_sortFilenameAscending);
    });

    // Sort by current sort method and polarity
    switch (currSortMethod) {
      case 'sortByTitle':
        _sortByTitle(_sortTitleAscending);
      case 'sortByModDate':
        _sortByModDate(_sortModDateAscending);
      case 'sortByFilename':
        _sortByFilename(_sortFilenameAscending);
      // case 'sortByOwner':
      //   _sortByOwner(_sortOwnerAscending);
      // case 'sortByPermission':
      //   _sortByPermission(_sortPermissionAscending);
    }
  }

  /// Update selected status and count of selected and add/remove note from
  /// selected notes list
  void updateSelected(int index) {
    setState(() {
      if (_foundNotes[index].isSelected) {
        // Decrement selected count
        selectedCount--;
        if (_foundNotes[index].isExternalRes) {
          extSelectedCount--;
        }

        // Remove note from selected notes list
        selectedNotes.removeWhere(
          (item) => item.noteFileName == _foundNotes[index].noteFileName,
        );
      } else {
        // Increment count
        selectedCount++;
        if (_foundNotes[index].isExternalRes) {
          extSelectedCount++;
        }
        // Add note to selected notes list
        selectedNotes.add(
          SelectedNote(
            noteFileName: _foundNotes[index].noteFileName,
            noteUrl: _foundNotes[index].noteUrl,
            noteOwner: _foundNotes[index].noteOwner,
          ),
        );
      }
      // Swap selected status of file
      _foundNotes[index].isSelected = !_foundNotes[index].isSelected;

      debugPrint('Selected notes:');
      for (final SelectedNote selectedNote in selectedNotes) {
        debugPrint(selectedNote.noteFileName);
      }
    });
  }

  /// Update multiple note selection mode
  void updateSelectionMode(bool selectionMode, int index) {
    setState(() {
      debugPrint(
        '_isSelectionMode before: $selectionMode, selectedCount: ${selectedCount.toString()}, extSelectedCount: ${extSelectedCount.toString()} isSelected: ${_foundNotes[index].isSelected}',
      );

      // Turn off selection mode if deselected only selected note
      // else turn on selection mode
      if (_foundNotes[index].isSelected && selectedCount == 1) {
        _isSelectionMode = false;
      } else {
        _isSelectionMode = true;
      }

      // Turn on external file selected
      if (_foundNotes[index].isSelected &&
          _foundNotes[index].isExternalRes &&
          extSelectedCount == 1) {
        // Turn off if the last selected external file has been deselected
        _isExtFileSelected = false;
      } else if (_isSelectionMode && _foundNotes[index].isExternalRes) {
        // Ensure on if any external file is selected
        _isExtFileSelected = true;
      }
      debugPrint('_isSelectionMode after: $_isSelectionMode');
      debugPrint('_isExtFileSelected after: $_isExtFileSelected');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reduce calls to of(context).
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        isVeryNarrow = SolidScaffoldHelpers.isVeryNarrowScreen(constraints);
        isNarrow = SolidScaffoldHelpers.isNarrowScreen(constraints);
        isWide = SolidScaffoldHelpers.isWideScreen(constraints);
        isVeryWide = SolidScaffoldHelpers.isVeryWideScreen(constraints);
        // debugPrint(
        //   'isVeryNarrow: $isVeryNarrow, isNarrow: $isNarrow, isWide: $isWide, isVeryWide: $isVeryWide',
        // );

        // Calculate the aspect radio for grid cards
        cardAspectRatio = NoteItemSize().calculateCardAspectRatio(constraints);
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
                      widget.title,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (value) => _searchNotes(value),
                      decoration: const InputDecoration(
                        labelText: 'Search notes',
                        hintText:
                            'Enter text to match title, content, or properties of note files',
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
                        Flexible(
                          child: selectedCount > 0
                              ? Text(
                                  'Selected: $selectedCount notes',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : _foundNotes.length > 1 || _foundNotes.isEmpty
                                  ? Text(
                                      'Found ${_foundNotes.length} notes',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Text(
                                      'Found ${_foundNotes.length} note',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: (!isVeryNarrow) ? 3.0 : 0,
                          children: [
                            // Multiple note delete button
                            // Only display multi note delete
                            // button when notes are selected causing
                            // isSelectionMode=true
                            // icon shows as inactive if _isExtFileSelect=true
                            if (_isSelectionMode) ...[
                              // Multi note delete button
                              NoteListDelButton(
                                selectedNotes: selectedNotes,
                                // Reload list after note deletion
                                childPage: ListNotesScreen(
                                  scaffoldController: _scaffoldController,
                                ),
                                scaffoldController: _scaffoldController,
                                isSelectionMode: _isSelectionMode,
                                isExtFileSelected: _isExtFileSelected,
                              ),
                            ],
                            // Title sort — always visible.
                            TextButton.icon(
                              onPressed: () {
                                _sortByTitle(!_sortTitleAscending);
                              },
                              icon: Icon(
                                _sortTitleAscending
                                    ? Icons.arrow_drop_down
                                    : Icons.arrow_drop_up,
                              ),
                              label: const Text(
                                'Title',
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                            // Date sort — hidden on very narrow screens
                            // to prevent overflow.
                            if (!isVeryNarrow) ...[
                              TextButton.icon(
                                onPressed: () {
                                  _sortByModDate(!_sortModDateAscending);
                                },
                                icon: Icon(
                                  _sortModDateAscending
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                ),
                                label: Text(
                                  isNarrow ? 'Date' : 'Date Modified',
                                ),
                                iconAlignment: IconAlignment.end,
                              ),
                            ],
                            // Filename sort — only on medium or wider screens.
                            if (!isVeryNarrow && !isNarrow) ...[
                              TextButton.icon(
                                onPressed: () {
                                  _sortByFilename(!_sortFilenameAscending);
                                },
                                icon: Icon(
                                  _sortFilenameAscending
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                ),
                                label: const Text(
                                  'Filename',
                                ),
                                iconAlignment: IconAlignment.end,
                              ),
                            ],
                            // // Owner Sort Label and Button
                            // TextButton.icon(
                            //   onPressed: () {
                            //     _sortByOwner(!_sortOwnerAscending);
                            //   },
                            //   icon: Icon(
                            //     _sortOwnerAscending
                            //         ? Icons.arrow_drop_down
                            //         : Icons.arrow_drop_up,
                            //   ),
                            //   label: const Text(
                            //     'Owner',
                            //   ),
                            //   iconAlignment: IconAlignment.end,
                            // ),
                            // Only display permissions sort
                            // when window is not narrow
                            // if (!isNarrow) ...[
                            //   // Permission Sort Label and Button
                            //   TextButton.icon(
                            //     onPressed: () {
                            //       _sortByPermission(!_sortPermissionAscending);
                            //     },
                            //     icon: Icon(
                            //       _sortPermissionAscending
                            //           ? Icons.arrow_drop_down
                            //           : Icons.arrow_drop_up,
                            //     ),
                            //     label: const Text(
                            //       'Permission',
                            //     ),
                            //     iconAlignment: IconAlignment.end,
                            //   ),
                            // ],
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
                      child: InkWell(
                        onTap: () {
                          // Open note if read in permissions
                          String access = _foundNotes[index].permissionList;
                          if (access.contains('read')) {
                            _scaffoldController.navigateToSubpage(
                              ViewNote(
                                note: _foundNotes[index],
                                scaffoldController: _scaffoldController,
                              ),
                            );
                          } else {
                            _scaffoldController.navigateToSubpage(
                              NonReadableNote(
                                note: _foundNotes[index],
                                scaffoldController: _scaffoldController,
                              ),
                            );
                          }
                        },
                        child: Ink(
                          decoration: _foundNotes[index].isSelected
                              ? BoxDecoration(
                                  color: theme.colorScheme.onInverseSurface,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                )
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: NoteIconSize.width,
                                  child: Center(
                                    child: Ink(
                                      decoration: buttonShapeList,
                                      child: IconButton(
                                        icon: _foundNotes[index].isSelected
                                            ? const Icon(Icons.done)
                                            : const Icon(Icons.edit_document),
                                        onPressed: () {
                                          updateSelectionMode(
                                            _isSelectionMode,
                                            index,
                                          );
                                          updateSelected(index);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_foundNotes[index]
                                          .permissionList
                                          .contains('read'))
                                        Text(
                                          _foundNotes[index].content!.noteTitle,
                                          maxLines: (!isVeryNarrow) ? 1 : 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      NoteItemSubtitle(
                                        note: _foundNotes[index],
                                        isNarrow: isVeryNarrow,
                                      ),
                                    ],
                                  ),
                                ),
                                NoteItemTrailingButtons(
                                  note: _foundNotes[index],
                                  scaffoldController: _scaffoldController,
                                ),
                              ],
                            ),
                          ),
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
