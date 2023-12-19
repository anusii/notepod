import 'package:flutter/material.dart';
import 'package:podnotes/common/responsive.dart';
import 'package:podnotes/constants/colours.dart';

Row buildMsgCard(
  BuildContext context,
  IconData errIcon,
  Color errColour,
  String errTitle,
  String errBody,
) {
  return Row(
    children: [
      Expanded(
        flex: Responsive.isDesktop(context) ? 10 : 8,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(60, 50, 60, 0),
          child: Card(
            elevation: 10,
            shadowColor: Colors.black,
            color: lighterGray,
            child: SizedBox(
              height: Responsive.isDesktop(context)
                  ? 160
                  : Responsive.isTablet(context)
                      ? 200
                      : 220,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        errIcon,
                        color: errColour,
                        size: 60,
                      ),
                    ), //CircleAvatar
                    const SizedBox(
                      height: 10,
                    ), //SizedBox
                    Text(
                      errTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ), //Textstyle
                    ), //Text
                    const SizedBox(
                      height: 10,
                    ), //SizedBox
                    Text(
                      errBody,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ), //Textstyle
                    ), //SizedBox
                  ],
                ), //Column
              ), //Padding
            ), //SizedBox
          ),
        ),
      ),
    ],
  );
}
