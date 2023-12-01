import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:podnotes/constants/file_structure.dart';
import 'package:podnotes/constants/rdf_functions.dart';
import 'package:podnotes/common/rest_api/rest_api.dart';
import 'package:solid_auth/solid_auth.dart';

String dividePubKeyStr(String keyStr) {
  final itemList = keyStr.split('\n');
  itemList.remove('-----BEGIN RSA PUBLIC KEY-----');
  itemList.remove('-----END RSA PUBLIC KEY-----');
  itemList.remove('-----BEGIN PUBLIC KEY-----');
  itemList.remove('-----END PUBLIC KEY-----');

  String keyStrTrimmed = itemList.join('');
  return keyStrTrimmed;
}

String genPubKeyStr(String keyStr) {
  return '''-----BEGIN RSA PUBLIC KEY-----\n$keyStr\n-----END RSA PUBLIC KEY-----''';
}

Future<bool> verifyEncKey(String plaintextEncKey, Map authData) async {
  String sha224Result =
      sha224.convert(utf8.encode(plaintextEncKey)).toString().substring(0, 32);

  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];
  Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

  // Get webID
  String webId = decodedToken['webid'];

  String encKeyFileUrl =
      webId.replaceAll('profile/card#me', '$encDirLoc/$encKeyFile');
  String dPopToken =
      genDpopToken(encKeyFileUrl, rsaKeyPair, publicKeyJwk, 'GET');

  String encKeyRes = await fetchPrvFile(encKeyFileUrl, accessToken, dPopToken);
  Map encFileContent = getFileContent(encKeyRes.toString());

  String encKeyHash = encFileContent['encKey'][1];

  if (encKeyHash != sha224Result) {
    // If the stored hash value is the same
    return false;
  } else {
    // If not
    return true;
  }
}
