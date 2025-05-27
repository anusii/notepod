/// App-wide constants.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:26:39 +1100 Graham Williams>
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
/// Authors: Anushka Vidanage, Graham Williams

library;

import 'package:flutter/material.dart';

const String applicationRepo = 'https://github.com/anusii/notepod';
const String siiUrl = 'https://sii.anu.edu.au';
const String topBarTitle = 'Note Taker for your Pod';

const String authors =
    'Authors: Anushka Vidanage, Graham Williams, Jess Moore.';

const kDefaultPadding = 20.0;
const double normalLoadingScreenHeight = 200.0;
const double buttonBorderRadius = 5;
const double standardSpace = 20.0;

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

const nonReadableNoteMsg =
    'You do not have read access to this note and therefore cannot view that. However, you can delete it or share it with others.';

const noNotesMsg = 'You do not have any notes yet!';

const noSharedNotesMsg = 'You do not have any shared notes yet!';

SizedBox standardHeight() {
  return const SizedBox(
    height: standardSpace / 2,
  );
}

const double desktopWidthThreshold = 960;
