import 'package:url_launcher/url_launcher.dart';
import 'package:solid_auth/solid_auth.dart';

Future<bool> logoutUser(String logoutUrl) async {
  if (await canLaunchUrl(Uri.parse(logoutUrl))) {
    await launchUrl(
      Uri.parse(logoutUrl),
      mode: LaunchMode.inAppWebView,
    );
  } else {
    throw 'Could not launch $logoutUrl';
  }
  await Future.delayed(const Duration(seconds: 4));
  if (currPlatform.isWeb()) {
    authManager.userLogout(logoutUrl);
  }

  return true;
}
