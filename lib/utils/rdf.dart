/// Common utilities for working on RDF data.
///
// Time-stamp: <Wednesday 2024-07-10 09:49:30 +1000 Graham Williams>
///
/// Copyright (C) 2024, Software Innovation Institute, ANU.
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

library;

import 'package:rdflib/rdflib.dart';

Map<String, dynamic> parseTTLMap(String ttlContent) {
  final g = Graph();
  g.parseTurtle(ttlContent);
  final dataMap = <String, dynamic>{};
  for (final t in g.triples) {
    final sub = t.sub.value as String;
    final pre = t.pre.value as String;
    final obj = t.obj.value as String;
    if (dataMap.containsKey(sub)) {
      if ((dataMap[sub] as Map).containsKey(pre)) {
        dataMap[sub][pre].add(obj);
      } else {
        dataMap[sub][pre] = {obj};
      }
    } else {
      dataMap[sub] = {
        pre: {obj},
      };
    }
  }
  return dataMap;
}
