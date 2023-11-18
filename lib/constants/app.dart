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
/// Authors: Anushka Vidanage

library;

import 'package:flutter/material.dart';

const darkGold = Color(0xFFBE830E);
const brickRed = Color(0xFFD89E7A);
const lightGreen = Color.fromARGB(255, 120, 219, 137);
const lightBlue = Color(0xFF61B2CE);
const exLightBlue = Color(0xFFD8ECF3);
const darkCopper = Color(0xFFBE4E0E);
const titleAsh = Color(0xFF30384D);
const backgroundWhite = Color(0xFFF5F6FC);
const lightGray = Color(0xFF8793B2);
const bgOffWhite = Color(0xFFF2F4FC);

const kDefaultPadding = 20.0;

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

// // Folders
// const List FOLDERS = [
//   MAIN_RES_DIR,
//   '$MAIN_RES_DIR/$SHARING_DIR',
//   '$MAIN_RES_DIR/$SHARED_DIR',
//   '$MAIN_RES_DIR/$MED_DIR',
//   '$MAIN_RES_DIR/$ENC_DIR',
//   '$MAIN_RES_DIR/$LOGS_DIR'
// ];
