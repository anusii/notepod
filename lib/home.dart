import 'package:flutter/material.dart';

import 'package:markdown_editor_plus/markdown_editor_plus.dart';
//import 'package:simple_markdown_editor/simple_markdown_editor.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

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
