/// Individual's PODs app for diabetes care in Yarrabah.
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
/// Authors: Zheyuan Xu, Graham Williams
library;

import 'package:flutter/material.dart';

import 'package:podnotes/constants/app.dart';
import 'package:podnotes/constants/rest_api.dart';
import 'package:podnotes/initial_setup/initial_setup_desktop.dart';
import 'package:podnotes/widgets/loading_screen.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen(
      {super.key, required this.authData, required this.webId});

  final Map authData;
  final String webId;

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Future? _asyncDataFetch;

  @override
  void initState() {
    Map authData = widget.authData;
    _asyncDataFetch = initialStructureTest(authData);
    super.initState();
  }

  Widget _loadedScreen(
      List resNotExist, String webId, String logoutUrl, Map authData) {
    Map resNeedToCreate = resNotExist.last;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
              child: InitialSetupDesktop(
                  resNeedToCreate: resNeedToCreate,
                  authData: authData,
                  webId: webId))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map authData = widget.authData;
    String webId = widget.webId;
    String logoutUrl = authData['logoutUrl'];

    return Scaffold(
      key: _scaffoldKey,
      // drawer: ConstrainedBox(
      //     constraints: BoxConstraints(maxWidth: sideMenuScreenSize),
      //     child: SideMenu(
      //       authData: authData,
      //       webId: webId,
      //       pageName: 'home',
      //       allResIn: false,
      //     )),
      // endDrawer: ConstrainedBox(
      //   constraints: BoxConstraints(maxWidth: 400),
      //   child: ListOfSurveys(authData: authData, webId: webId)
      // ),
      body: SafeArea(
        child: FutureBuilder(
            future: _asyncDataFetch,
            builder: (context, snapshot) {
              Widget returnVal;
              if (snapshot.connectionState == ConnectionState.done) {
                returnVal = _loadedScreen(
                    snapshot.data! as List, webId, logoutUrl, authData);
              } else {
                returnVal = loadingScreen(normalLoadingScreenHeight);
              }
              return returnVal;
            }),
      ),
    );
  }
}
