// test_ilxd_zk_bridge.dart
// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>

import 'dart:typed_data';
import 'package:ilxd_bridge/ilxd_zk_bridge.dart';

int testLoadPublicParams() {
  int failed = 0;
  try {
    print('testLoadPublicParams: Loading public parameters...');
    IlxdZkBridge.loadPublicParams();
    print('testLoadPublicParams: Public parameters loaded successfully.');
  } catch (e) {
    print('testLoadPublicParams: Error: $e');
    failed = 1;
  }
  return failed;
}

int testLurkCommit() {
  int failed = 0;
  final expr = '555'; // Example Lurk expression

  try {
    final result = IlxdZkBridge.lurkCommit(expr);
    print('testLurkCommit: Lurk commit result: ${result.length} bytes');
    print(
        'testLurkCommit: Hex representation: ${result.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('testLurkCommit Error: $e');
    failed = 1;
  }
  return failed;
}

int testCreateProof() {
  int failed = 0;
  String lurkProgram = '''(lambda (priv pub) (letrec ((or (lambda (a b)
                                                             (eval (cons 'coproc_or (cons a (cons b nil)))))))
                                                     (= (or 19 15) 31)))''';
  String privateParams = "(cons 7 8)";
  String publicParams = '';
  int maxSteps = 100;
  Uint8List proof = Uint8List(32);
  proof.fillRange(0, 32, 0);
  Uint8List outputTag = Uint8List(32);
  outputTag.fillRange(0, 32, 0);
  Uint8List outputVal = Uint8List(32);
  outputVal.fillRange(0, 32, 0);

  try {
    IlxdZkBridge.createProof(
        lurkProgram, privateParams, publicParams, maxSteps, proof, outputTag, outputVal);
    print('testCreateProof: success');
  } catch (e) {
    print('testCreateProof Error: $e');
    failed = 1;
  }
  return failed;
}

void main() async {
  int failed = 0;
  failed += testLurkCommit();
  failed += testLoadPublicParams();
  failed += testCreateProof();

  if (failed == 0) {
    print('OK: test_ilxd_zk_bridge: ALL TESTS PASSED.');
  } else {
    print('KO: test_ilxd_zk_bridge: $failed failed tests.');
  }
}
