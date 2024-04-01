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

  // int lurk_commit(const char* expr, uint8_t* out);
  static final _lurkCommit = _dylib.lookupFunction<Int32 Function(Pointer<Utf8>, Pointer<Uint8>), int Function(Pointer<Utf8>, Pointer<Uint8>)>('lurk_commit');

  // int create_proof_ffi(const char* lurk_program, const char* private_params, const char* public_params, size_t max_steps, uint8_t* proof, size_t* proof_len, uint8_t* output_tag, uint8_t* output_val);
  static final _createProof = _dylib.lookupFunction<Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, IntPtr, Pointer<Uint8>, Pointer<IntPtr>, Pointer<Uint8>, Pointer<Uint8>), int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, int, Pointer<Uint8>, Pointer<IntPtr>, Pointer<Uint8>, Pointer<Uint8>)>('create_proof_ffi');

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

  //int create_proof_ffi(const char* lurk_program, const char* private_params, const char* public_params, size_t max_steps, uint8_t* proof, size_t* proof_len, uint8_t* output_tag, uint8_t* output_val);
  static Future<void> createProof(String lurkProgram, String privateParams, String publicParams, int maxSteps, Uint8List proof, Uint8List outputTag, Uint8List outputVal) async {
    final lurkProgramPtr = lurkProgram.toNativeUtf8();
    final privateParamsPtr = privateParams.toNativeUtf8();
    final publicParamsPtr = publicParams.toNativeUtf8();

    // Create a Pointer<Uint8> and have it point to where proof is stored
    final proofPtr = malloc.allocate<Uint8>(proof.length);
    proofPtr.asTypedList(OutLen).setAll(0, proof);

    // Create a Pointer<Uint8> and have it point to where outputTag is stored
    final outputTagPtr = malloc.allocate<Uint8>(outputTag.length);
    outputTagPtr.asTypedList(OutLen).setAll(0, outputTag);

    // Create a Pointer<Uint8> and have it point to where outputVal is stored
    final outputValPtr = malloc.allocate<Uint8>(outputVal.length);
    outputValPtr.asTypedList(OutLen).setAll(0, outputVal);

    // set the value of proofLen inside proofLenPtr;
    final proofLenPtr = malloc.allocate<IntPtr>(1);
    proofLenPtr.value = proof.length;
    final result = _createProof(lurkProgramPtr, privateParamsPtr, publicParamsPtr, maxSteps, proofPtr, proofLenPtr, outputTagPtr, outputValPtr);

    if (result != 0) {
      throw Exception('Proof creation failed with error code: $result');
    }

    // print the output tags and output vals
    print('IlxdBridge::createProof() -> ');
    for (int i = 0; i < 32; i++) {
      print('outputTag[$i] = ${outputTag[i]}');
      print('outputVal[$i] = ${outputVal[i]}');
      print('');
    }

    malloc.free(lurkProgramPtr);
    malloc.free(privateParamsPtr);
    malloc.free(publicParamsPtr);
    malloc.free(proofLenPtr);
  }
}