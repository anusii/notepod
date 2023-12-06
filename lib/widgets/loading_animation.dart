import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:podnotes/constants/colours.dart';

showAnimationDialog(
  BuildContext context,
  int animationIndex,
  String alertMsg,
  bool showPathBackground,
) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(50),
        child: Center(
          // child: SpinKitThreeBounce(
          //   color: anuCopper,
          //   size: 100.0,
          //   //controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
          // ),
          child: SizedBox(
            width: 150,
            height: 250,
            child: Column(
              children: [
                LoadingIndicator(
                  indicatorType: Indicator.values[animationIndex],
                  colors: defaultPodnotesColors,
                  strokeWidth: 4.0,
                  pathBackgroundColor: showPathBackground
                      ? const Color.fromARGB(59, 0, 0, 0)
                      : null,
                ),
                DefaultTextStyle(
                  style: (const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  )),
                  child: Text(
                    alertMsg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
