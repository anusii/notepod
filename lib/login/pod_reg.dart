// POD issuer registration page launch
import 'package:openid_client/openid_client.dart';
import 'package:url_launcher/url_launcher.dart';

launchIssuerReg(String issuerUri) async {
  // Get issuer metatada
  Issuer issuer = await Issuer.discover(Uri.parse(issuerUri));

  // Get end point URIs
  String regEndPoint = issuer.metadata['issuer'];

  if (await canLaunchUrl(Uri.parse(regEndPoint))) {
    await launchUrl(Uri.parse(regEndPoint));
  } else {
    throw 'Could not launch $regEndPoint';
  }
}
