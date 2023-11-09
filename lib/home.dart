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

import 'package:flutter/material.dart';

import 'package:markdown_editor_plus/markdown_editor_plus.dart';
//import 'package:simple_markdown_editor/simple_markdown_editor.dart';

class Home extends StatefulWidget {
  String webId;
  Map authData;

  Home({Key? key, required this.webId, required this.authData})
      : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
        title: const Text("POD Note Taker"),
      ),
      body: MarkdownAutoPreview(
        controller: _textController,
        enableToolBar: true,
        emojiConvert: true,
        // autoCloseAfterSelectEmoji: false,
        // onChanged: (String text) {
        //   setState(() {
        //     this.text = text;
        //   });
        // },
      ),
    );
  }
}
