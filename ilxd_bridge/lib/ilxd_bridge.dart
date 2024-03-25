// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

class IlxdBridge {

  static String _getLibPath() {
    String cwd =  Directory.current.path.toString();
    String osName = '';
    String arch = '';
    String libExt = 'so';

    if (Platform.isMacOS) {
      osName = 'macos';
    } else if (Platform.isIOS) {
      osName = 'ios';
    } else if (Platform.isAndroid) {
      osName = 'android';
    } else if (Platform.isWindows) {
      osName = 'win';
    }

    if (Platform.version.contains('arm64') || Platform.version.contains('aarch64')) {
      arch = 'arm64';
    } else if (Platform.version.contains('x86_64')) {
      arch = 'x86_64';
    } else if (Platform.version.contains('x86')) {
      arch = 'x86';
    }

    if (Platform.isMacOS || Platform.isIOS) {
      libExt = 'dylib';
    }

    if (Platform.isWindows) {
      libExt = 'dll';
    }

    if (osName.isEmpty || arch.isEmpty || libExt.isEmpty) {
      return '';
    }

    String result = '${cwd}/${osName}/libilxd_bridge_${osName}_${arch}.${libExt}';
    print('IlxdBridge::_getLibPath() -> ${result}');
    return result;
  }

  static const OutLen = 32;

  static final DynamicLibrary _dylib = DynamicLibrary.open(_getLibPath());

  static final _lurkCommit = _dylib.lookupFunction<Int32 Function(Pointer<Utf8>, Pointer<Uint8>), int Function(Pointer<Utf8>, Pointer<Uint8>)>('lurk_commit');

  static Future<Uint8List> lurkCommit(String expr) async {
    final exprPtr = expr.toNativeUtf8();
    final outputBuffer = malloc.allocate<Uint8>(OutLen);

    try {
      final result = _lurkCommit(exprPtr, outputBuffer);
      if (result != 0) {
        throw Exception('Lurk commit failed with error code: $result');
      }

      final output = Uint8List.fromList(outputBuffer.asTypedList(OutLen));
      print('ilxd_bridge:LurkBridge.lurkCommit(...) invoked with no issues');
      return output;
    } finally {
      malloc.free(exprPtr);
      malloc.free(outputBuffer);
    }
  }
}