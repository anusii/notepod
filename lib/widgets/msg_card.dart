/// DESCRIPTION
///
// Time-stamp: <Friday 2025-06-27 13:54:18 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
/// Authors: AUTHORS

library;

import 'package:flutter/material.dart';

import 'package:notepod/common/responsive.dart';
import 'package:notepod/constants/colours.dart';

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
