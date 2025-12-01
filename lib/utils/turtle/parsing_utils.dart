/// Turtle parsing utilities
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// Time-stamp: <Friday 2025-10-03 13:56:10 +1100 Graham Williams>
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
/// Authors: Jess Moore

library;

import 'package:solidpod/solidpod.dart' show turtleToTripleMap;

/// Turtle parsing utilities.

class TurtleParsingUtils {
  /// Safely parses TTL content to triple map.

  static Map<String, Map<String, List<dynamic>>>? safeParseTtlToTriple(
    String ttlContent,
  ) {
    try {
      return turtleToTripleMap(ttlContent);
    } catch (e) {
      return null;
    }
  }
}
