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
