/// The home page for the app.
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
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:podnotes/constants/colours.dart';
//import 'package:simple_markdown_editor/simple_markdown_editor.dart';

class Home extends StatefulWidget {
  final String webId;
  final Map authData;

  const Home({super.key, required this.webId, required this.authData});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TextEditingController? _textController;

  String text = "";

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(10),
            child: SplittedMarkdownFormField(
              controller: _textController,
              markdownSyntax: '## Headline',
              decoration: const InputDecoration(
                hintText: 'Editable text',
              ),
              emojiConvert: true,
            )),
        const SizedBox(
          height: 20,
        ),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () async {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: darkBlue,
                  backgroundColor: lightBlue, // foreground
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'SAVE NOTE',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        )
      ],
    );
    // Column(
    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //   children: [
    //     // const MarkdownAutoPreview(
    //     //   decoration: InputDecoration(
    //     //     hintText: 'Markdown Auto Preview',
    //     //   ),
    //     //   emojiConvert: true,
    //     //   // maxLines: 10,
    //     //   // minLines: 1,
    //     //   // expands: true,
    //     // ),
    //     SplittedMarkdownFormField(
    //       controller: _textController,
    //       markdownSyntax: '## Headline',
    //       decoration: const InputDecoration(
    //         hintText: 'Splitted Markdown FormField',
    //       ),
    //       emojiConvert: true,
    //     ),
    //   ],
    // );
    // Container(
    //   padding: const EdgeInsets.all(10),
    //   child: SafeArea(
    //     child: MarkdownAutoPreview(
    //       controller: _textController,
    //       enableToolBar: true,
    //       emojiConvert: true,
    //       // autoCloseAfterSelectEmoji: false,
    //       // onChanged: (String text) {
    //       //   setState(() {
    //       //     this.text = text;
    //       //   });
    //       // },
    //     ),
    //   ),
    // );
  }
}
