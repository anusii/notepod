/// The edit note page.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:32:47 +1100 Graham Williams>
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
/// Authors: Anushka Vidanage, Graham Williams, Jess Moore

library;

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:notepod/constants/colours.dart';
import 'package:notepod/constants/turtle_structures.dart';
import 'package:notepod/notes/view_note.dart';
import 'package:notepod/utils/save_note.dart';
import 'package:notepod/widgets/markdown_editor.dart';
import 'package:notepod/widgets/note_back_button.dart';

class EditNote extends StatefulWidget {
  final Map noteData;

  const EditNote({super.key, required this.noteData});

  @override
  EditNoteState createState() => EditNoteState();
}

class EditNoteState extends State<EditNote>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormBuilderState>();

  TextEditingController? _textController;
  late final FocusNode _focusNode;

  String data = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController!.text = widget.noteData[noteContentPred];
    // Start listening to changes.
    _textController!.addListener(_renderMarkdown);
    _focusNode = FocusNode();
    // To enable the ENTER => SAVE functionality within a note, replace the
    // above line with the following. For now we will stay with current
    // behaviour. (20250714 gjw).
    //
    // _focusNode = FocusNode(
    //   onKeyEvent: (FocusNode node, KeyEvent evt) {
    //     if (!HardwareKeyboard.instance.isShiftPressed &&
    //         evt.logicalKey.keyLabel == 'Enter') {
    //       if (evt is KeyDownEvent) {
    //         // Save note when enter (not shift-enter) pressed
    //         saveNote(context, _textController!, formKey, widget.noteData);
    //       }
    //       return KeyEventResult.handled;
    //     } else {
    //       return KeyEventResult.ignored;
    //     }
    //   },
    // );
  }

  @override
  void dispose() {
    _textController!.dispose(); // Dispose the TextEditingController
    _focusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  void _renderMarkdown() {
    setState(() {
      data = _textController!.text;
      ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FormBuilder(
                key: formKey,
                onChanged: () {
                  formKey.currentState!.save();
                  debugPrint(formKey.currentState!.value.toString());
                },
                autovalidateMode: AutovalidateMode.disabled,
                skipDisabled: true,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: noteTitlePred,
                      initialValue: widget.noteData[noteTitlePred],
                      decoration: const InputDecoration(
                        labelText: 'Note Title',
                        labelStyle: TextStyle(
                          color: darkBlue,
                          letterSpacing: 1.5,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                        //errorText: 'error',
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                  ],
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          markdownEditor(context, _textController!, _focusNode, data),

          // Container(
          //   padding: const EdgeInsets.all(10),
          //   child: MarkdownAutoPreview(
          //     controller: _textController,
          //     decoration: InputDecoration(
          //       hintText: 'Input markdown text',
          //     ),
          //     emojiConvert: true,
          //     hintText: 'Tap here to start writing a note!',
          //     // maxLines: 10,
          //     // minLines: 1,
          //     // expands: true,
          //   ),
          //   // SplittedMarkdownFormField(
          //   //   controller: _textController,
          //   //   markdownSyntax: '## Headline',
          //   //   decoration: const InputDecoration(
          //   //     hintText: 'Editable text',
          //   //   ),
          //   //   emojiConvert: true,
          //   // )
          // ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await saveNote(
                        context, _textController!, formKey, widget.noteData);

                    // Redirect to the home page
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: darkBlue,
                    backgroundColor: lightBlue, // foreground
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'SAVE CHANGES',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                NoteBackButton(childPage: ViewNote(noteData: widget.noteData)),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
