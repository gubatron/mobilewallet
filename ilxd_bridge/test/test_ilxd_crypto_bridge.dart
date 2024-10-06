// test_ilxd_crypto_bridge.dart
// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>

import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:ilxd_bridge/ilxd_crypto_bridge.dart';

int testGenerateSecretKey() {
  int failed = 0;
  try {
    final secretKey = IlxdCryptoBridge.generateSecretKey();
    print(
        'testGenerateSecretKey: Generated secret key: ${secretKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('testGenerateSecretKey Error: $e');
    failed = 1;
  }
  return failed;
}

int testSecretKeyFromSeed() {
  int failed = 0;
  final seed = Uint8List.fromList(List.generate(32, (index) => index));

  try {
    final secretKey = IlxdCryptoBridge.secretKeyFromSeed(seed);
    print(
        'testSecretKeyFromSeed: Secret key from seed: ${secretKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('testSecretKeyFromSeed Error: $e');
    failed = 1;
  }
  return failed;
}

int testPrivToPub() {
  int failed = 0;
  final privKey = IlxdCryptoBridge.generateSecretKey();

  try {
    final pubKey = IlxdCryptoBridge.privToPub(privKey);
    print(
        'testPrivToPub: Public key: ${pubKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('testPrivToPub: Error: $e');
    failed = 1;
  }
  return failed;
}

int testCompressedToFull() {
  int failed = 0;
  final privKey = IlxdCryptoBridge.generateSecretKey();
  final pubKey = IlxdCryptoBridge.privToPub(privKey);
  final outX = Uint8List(32);
  final outY = Uint8List(32);

  try {
    IlxdCryptoBridge.compressedToFull(pubKey, outX, outY);
    print(
        'testCompressedToFull: X-coordinate: ${outX.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
    print(
        'testCompressedToFull: Y-coordinate: ${outY.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('testCompressedToFull: Error: $e');
    failed = 1;
  }
  return failed;
}

int testSign() {
  int failed = 0;
  final privKey = IlxdCryptoBridge.generateSecretKey();
  final message = 'Hello, world!';
  final messageDigest = Uint8List.fromList(sha256.convert(message.codeUnits).bytes);

  try {
    final signature = IlxdCryptoBridge.sign(privKey, messageDigest);
    print(
        'testSign: Signature: ${signature.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('testSign: Error: $e');
    failed = 1;
  }
  return failed;
}

int testVerify() {
  int failed = 0;
  final privKey = IlxdCryptoBridge.generateSecretKey();
  final pubKey = IlxdCryptoBridge.privToPub(privKey);
  final message = 'Hello, world!';
  final messageDigest = Uint8List.fromList(sha256.convert(message.codeUnits).bytes);
  final signature = IlxdCryptoBridge.sign(privKey, messageDigest);
  final sigR = signature.sublist(0, 32);
  final sigS = signature.sublist(32);

  try {
    final isValid = IlxdCryptoBridge.verify(pubKey, messageDigest, sigR, sigS);
    print('testVerify: Signature is valid: $isValid');
  } catch (e) {
    print('testVerify: Error: $e');
    failed = 1;
  }
  return failed;
}

void main() async {
  int failed = 0;
  failed += testGenerateSecretKey();
  failed += testSecretKeyFromSeed();
  failed += testPrivToPub();
  failed += testCompressedToFull();
  failed += testSign();
  failed += testVerify();

  if (failed == 0) {
    print('OK: test_ilxd_crypto_bridge: ALL TESTS PASSED.');
  } else {
    print('KO: test_ilxd_crypto_bridge: $failed failed tests.');
  }
}
