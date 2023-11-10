import 'package:flutter/material.dart';
import 'package:podnotes/common/app.dart';
import 'package:podnotes/common/colours.dart';

Widget loadingScreen(double height) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Container(
        alignment: AlignmentDirectional.center,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Container(
          decoration: BoxDecoration(
              color: lightBlue, borderRadius: BorderRadius.circular(25.0)),
          width: 300.0,
          height: height,
          alignment: AlignmentDirectional.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Center(
                child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator(
                    value: null,
                    color: Colors.white,
                    strokeWidth: 7.0,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 25.0),
                child: const Center(
                  child: Text(
                    "Loading.. Please wait!",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
