/// DESCRIPTION
///
// Time-stamp: <Friday 2025-06-27 13:54:18 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
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
/// Authors: AUTHORS

library;

import 'package:flutter/material.dart';

import 'package:notepod/common/responsive.dart';
import 'package:notepod/constants/colours.dart';

/// Builds a stylised card for display of messages,
/// which works in light and dark themes
Row buildMsgCard(
  BuildContext context,
  IconData errIcon,
  Color errColour,
  String errTitle,
  String errBody, {
  bool isSmall = false,
}) {
  // Call buildMsgCard with isSmall=true to use above another widget
  EdgeInsets paddingMsgCardDef = const EdgeInsets.fromLTRB(60, 50, 60, 20);
  EdgeInsets paddingMsgCardSmall = const EdgeInsets.fromLTRB(60, 20, 60, 20);

  Map<String, Map<String, double>> msgCardHeightSettings = {
    'desktop': {'smallmsg': 140, 'normalmsg': 160},
    'tablet': {'smallmsg': 150, 'normalmsg': 200},
    'other': {'smallmsg': 160, 'normalmsg': 220},
  };

  double heightMsgCard = isSmall
      ? (Responsive.isDesktop(context)
          ? msgCardHeightSettings['desktop']!['smallmsg'] as double
          : Responsive.isTablet(context)
              ? msgCardHeightSettings['tablet']!['smallmsg'] as double
              : msgCardHeightSettings['other']!['smallmsg'] as double)
      : (Responsive.isDesktop(context)
          ? msgCardHeightSettings['desktop']!['normalmsg'] as double
          : Responsive.isTablet(context)
              ? msgCardHeightSettings['tablet']!['normalmsg'] as double
              : msgCardHeightSettings['other']!['normalmsg'] as double);

  return Row(
    children: [
      Expanded(
        flex: Responsive.isDesktop(context) ? 10 : 8,
        child: Padding(
          padding: isSmall ? paddingMsgCardSmall : paddingMsgCardDef,
          child: Card(
            elevation: 10,
            shadowColor: Colors.black,
            color: lighterGray,
            child: SizedBox(
              // height: Responsive.isDesktop(context)
              //     ? 160
              //     : Responsive.isTablet(context)
              //         ? 200
              //         : 220,
              height: heightMsgCard,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    ), //CircleAvatar //SizedBox
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        errTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ), //Textstyle
                        overflow: TextOverflow.ellipsis,
                      ),
                    ), //Text//SizedBox
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        errBody,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ), //Textstyle
                        overflow: TextOverflow.ellipsis,
                      ),
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
