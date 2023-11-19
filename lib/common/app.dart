// Flutter imports:
import 'package:flutter/material.dart';

const kDefaultPadding = 20.0;
const double normalLoadingScreenHeight = 200.0;

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

// Const text labels
const loginTimeoutTitle = 'Login Timeout!';
const loginTimeoutError =
    'Your login session has expired! Please login again to continue.';

const initialStructureWelcome =
    '''Welcome to PODNotes initial structure setup wizard!''';

const initialStructureTitle = '''Structure setup wizard!''';

const initialStructureMsg =
    'You are being re-directed to this page because you have either created a completely new POD and you will need to setup the initial resource structure to start using the app OR we have detected some missing files and/or folders in your POD that will prevent you from using some functionalities of the app, and therefore need to be re-created.';

const requiredPwdMsg =
    'We would also need a password (a master key) for the encryption of notes. For this password you can use the same password you use for login to your POD (not recommended) or a completely different password (highly recommended). Please enter your password below.';

const publicKeyMsg =
    'We will also create a random public/private key pair for secure data sharing with other PODs.';
