// Misc functions.
///
// Time-stamp: <Friday 2025-06-27 14:00:17 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
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
/// Authors: Anushka Vidanage

import 'package:intl/intl.dart';

String capitalize(String word) =>
    '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';

// Get the profile name from the webId
String getNameFromWebId(String webId) {
  String name = webId.split('/').reversed.elementAt(2);
  List nameList = name.split('-');

  List capNameList = [];
  for (final subName in nameList) {
    String capName = capitalize(subName);
    capNameList.add(capName);
  }

  return capNameList.join(' ');
}

// Date format type for displaying date and time.
enum DateFormatType {
  defaultFormat,
  longDate,
  longDateTime,
}

// Get the given date and time in a specific format.
String getDateTimeStr(
  String dateTimeStr, {
  DateFormatType formatType = DateFormatType.defaultFormat,
}) {
  String pattern;
  switch (formatType) {
    case DateFormatType.longDate:
      pattern = 'dd MMM yyyy';
      break;
    case DateFormatType.longDateTime:
      pattern = 'dd MMM yyyy hh:mm:ss a';
      break;
    case DateFormatType.defaultFormat:
      // default:
      pattern = 'dd/MM/yyyy hh:mm:ss a';
  }
  final dateFormat = DateFormat(pattern);
  return dateFormat.format(DateTime.parse(dateTimeStr));
}
