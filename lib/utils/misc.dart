// Misc functions.
///
// Time-stamp: <Monday 2025-07-14 10:36:05 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
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
/// Authors: Anushka Vidanage
library;

import 'package:intl/intl.dart';

String capitalize(String word) =>
    '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';

// // Get the profile name from the webId
// String getNameFromWebId(String webId) {
//   String name = webId.split('/').reversed.elementAt(2);
//   List nameList = name.split('-');

//   List capNameList = [];
//   for (final subName in nameList) {
//     String capName = capitalize(subName);
//     capNameList.add(capName);
//   }

//   return capNameList.join(' ');
// }

// Date format type for displaying date and time.

enum DateFormatType {
  defaultFormat,
  longDate,
  longDateTime,
}

/// Get the given date and time in a specific format.
///
/// The default for the optional argument is the most readily human readable,
/// suggested as `4 Jul 2025 8:45 AM`. The leading zero on the day and hour are
/// dropped, as well as seconds. (20250714 gjw)

String getDateTimeStr(
  String dateTimeStr, {
  DateFormatType formatType = DateFormatType.defaultFormat,
}) {
  String pattern;
  switch (formatType) {
    case DateFormatType.longDate:
      pattern = 'd MMM yyyy';
      break;
    case DateFormatType.longDateTime:
      pattern = 'dd/MM/yyyy hh:mm:ss a';
      break;
    case DateFormatType.defaultFormat:
      // default:
      pattern = 'd MMM yyyy h:mm a';
  }
  final dateFormat = DateFormat(pattern);
  return dateFormat.format(DateTime.parse(dateTimeStr));
}

/// Get the number of recipients with access to a file, and return as a
/// String. Where the number of recipients is the number of webIDs with
/// file access minus one (to exclude the file owner).
///
/// Parameters:
/// [totalNbr] - The total number of webIDs in the permission table
///              of a resource.
///
String getRecipNbrStr(
  int totalNbr,
) {
  return (totalNbr - 1).toString();
}
