// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>
import 'dart:io';
import 'package:ilxd_bridge/ilxd_bridge.dart';

void main() async {
  final expr = '(+ 1 2)'; // Example Lurk expression

  try {
    final result = await IlxdBridge.lurkCommit(expr);
    print('Lurk commit result: ${result.length} bytes');
    print('Hex representation: ${result.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
  } catch (e) {
    print('Error: $e');
  }
}