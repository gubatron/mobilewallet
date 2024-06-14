// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>
import 'dart:io';
import 'dart:typed_data';
import 'package:ilxd_bridge/ilxd_zk_bridge.dart';
import 'package:ilxd_bridge/ilxd_crypto_bridge.dart';
import 'package:crypto/crypto.dart';

void testLurkCommit() {
  final expr = '555'; // Example Lurk expression

  try {
    final result = IlxdZkBridge.lurkCommit(expr);
    print('Lurk commit result: ${result.length} bytes');
    print('Hex representation: ${result.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('Error: $e');
  }
}

void testCreateProof() {
  //String lurkProgram, String privateParams, String publicParams, int maxSteps, Uint8List proof, Uint8List outputTag, Uint8List outputVal
  String lurkProgram = '(+ 1 2)';
  String privateParams = '';
  String publicParams = '';
  int maxSteps = 100;
  Uint8List proof = Uint8List(32);
  proof.fillRange(0, 32, 0);
  Uint8List outputTag = Uint8List(32);
  outputTag.fillRange(0, 32, 0);
  Uint8List outputVal = Uint8List(32);
  outputVal.fillRange(0, 32, 0);

  try {
    IlxdZkBridge.createProof(lurkProgram, privateParams, publicParams, maxSteps, proof, outputTag, outputVal);
  } catch (e) {
    print('Error: $e');
  }
}

void testGenerateSecretKey() {
  try {
    final secretKey = IlxdCryptoBridge.generateSecretKey();
    print('Generated secret key: ${secretKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('Error: $e');
  }
}

void testSecretKeyFromSeed() {
  final seed = Uint8List.fromList(List.generate(32, (index) => index));

  try {
    final secretKey = IlxdCryptoBridge.secretKeyFromSeed(seed);
    print('Secret key from seed: ${secretKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('Error: $e');
  }
}

void testPrivToPub() {
  final privKey = IlxdCryptoBridge.generateSecretKey();

  try {
    final pubKey = IlxdCryptoBridge.privToPub(privKey);
    print('Public key: ${pubKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('Error: $e');
  }
}

void testCompressedToFull() {
  final privKey = IlxdCryptoBridge.generateSecretKey();
  final pubKey = IlxdCryptoBridge.privToPub(privKey);
  final outX = Uint8List(32);
  final outY = Uint8List(32);

  try {
    IlxdCryptoBridge.compressedToFull(pubKey, outX, outY);
    print('X-coordinate: ${outX.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
    print('Y-coordinate: ${outY.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('Error: $e');
  }
}

void testSign() {
  final privKey = IlxdCryptoBridge.generateSecretKey();
  final message = 'Hello, world!';
  final messageDigest = Uint8List.fromList(sha256.convert(message.codeUnits).bytes);

  try {
    final signature = IlxdCryptoBridge.sign(privKey, messageDigest);
    print('Signature: ${signature.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('Error: $e');
  }
}

void testVerify() {
  final privKey = IlxdCryptoBridge.generateSecretKey();
  final pubKey = IlxdCryptoBridge.privToPub(privKey);
  final message = 'Hello, world!';
  final messageDigest = Uint8List.fromList(sha256.convert(message.codeUnits).bytes);
  final signature = IlxdCryptoBridge.sign(privKey, messageDigest);
  final sigR = signature.sublist(0, 32);
  final sigS = signature.sublist(32);

  try {
    final isValid = IlxdCryptoBridge.verify(pubKey, messageDigest, sigR, sigS);
    print('Signature is valid: $isValid');
  } catch (e) {
    print('Error: $e');
  }
}

void main() async {
  testLurkCommit();
  testCreateProof();
  testGenerateSecretKey();
  testSecretKeyFromSeed();
  testPrivToPub();
  testCompressedToFull();
  testSign();
  testVerify();
}