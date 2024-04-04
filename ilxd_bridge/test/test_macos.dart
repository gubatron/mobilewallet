// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>
import 'dart:io';
import 'dart:typed_data';
import 'package:ilxd_bridge/ilxd_zk_bridge.dart';

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

void main() async {
  testLurkCommit();
  testCreateProof();
}
