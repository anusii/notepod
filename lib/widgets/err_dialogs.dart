// Package imports.
import 'package:flutter/material.dart';

Future<void> showErrDialog(BuildContext context, String errMsg) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('ERROR!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(errMsg),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
