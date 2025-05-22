// Encryption functions.
//
// Copyright (C) 2025, Software Innovation Institute, ANU.
//
// Licensed under the GNU General Public License, Version 3 (the "License").
//
// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
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
//
// Authors: Anushka Vidanage

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// A function for ecrypting a plaintext value
///
/// Takes the arguments plaintext value and the encryption key
/// and returns a string of the encrypted value.
/// Note: AES encryption is used in this function. For more
/// details see: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard

String encryptVal(String plaintextStr, String encKey) {
  String encKeySha256 =
      sha256.convert(utf8.encode(encKey)).toString().substring(0, 32);
  final keyEncode = Key.fromUtf8(encKeySha256);
  final encrypter = Encrypter(AES(keyEncode, mode: AESMode.cbc));
  final encryptVal = encrypter.encrypt(plaintextStr, iv: getDummyIv());
  String encryptValStr = encryptVal.base64.toString();
  return encryptValStr;
}

/// A function for decrypting an encypted value
///
/// Takes the arguments encrypted value and the encryption key
/// and then returns the decrypted string value

String decryptVal(String encValStr, String encKey) {
  String encKeySha256 =
      sha256.convert(utf8.encode(encKey)).toString().substring(0, 32);
  final keyEncode = Key.fromUtf8(encKeySha256);
  final encrypter = Encrypter(AES(keyEncode, mode: AESMode.cbc));
  final decrypter = Encrypted.from64(
    encValStr,
  );
  final decryptValStr = encrypter.decrypt(decrypter, iv: getDummyIv());
  return decryptValStr;
}

IV getDummyIv() {
  var ivBtyes = Uint8List.fromList(
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
  return IV(ivBtyes);
}
