/// The LoginAgainScreen displays an error screen when the user's login session has expired.
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://www.gnu.org/licenses/gpl-3.0.en.html
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
///
import 'package:flutter/material.dart';
import 'package:podnotes/common/responsive.dart';
import 'package:podnotes/constants/app.dart';
import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/login/screen.dart';

class TokenExpiry extends StatefulWidget {
  final Map authData;
  final String webId;
  const TokenExpiry({
    super.key,
    required this.authData,
    required this.webId,
  });

  @override
  State<TokenExpiry> createState() => _TokenExpiryState();
}

class _TokenExpiryState extends State<TokenExpiry> {
  @override
  Widget build(BuildContext context) {
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
                height: 210,
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
                        child: const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 60,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ), //SizedBox
                      const Text(
                        tokenTimeOutTitle,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ), //Text
                      const SizedBox(
                        height: 10,
                      ), //SizedBox
                      const Text(
                        tokenTimeOutErr,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ), //SizedBox
                      SizedBox(
                        width: 170,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(darkBlue),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  color: backgroundWhite,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Login Again',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: backgroundWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}
