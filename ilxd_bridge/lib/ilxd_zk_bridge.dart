// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>

import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io';
import 'package:ilxd_bridge/ilxd_common.dart';
import 'package:ffi/ffi.dart';

class IlxdZkBridge {
  static const OutLen = 32;

  static DynamicLibrary? _dylib;

  // Method to get the DynamicLibrary, ensures lazy initialization
  static DynamicLibrary getDyLib() {
    if (_dylib == null) {
      final libPath = IlxdCommon.getLibPath(Library.ZK);
      print('Loading dynamic library from path: $libPath');
      if (libPath.isEmpty) {
        throw Exception('Dynamic library path is empty. Cannot load the library.');
      }
      if (!File(libPath).existsSync()) {
        throw Exception('Dynamic library not found at path: $libPath');
      }
      _dylib = DynamicLibrary.open(libPath);
    }
    return _dylib!;
  }

  // int lurk_commit(const char* expr, uint8_t* out);
  static void _lurkCommit(Pointer<Utf8> exprPtr, Pointer<Uint8> out) {
    final lurkCommit = getDyLib().lookupFunction<
        Int32 Function(Pointer<Utf8>, Pointer<Uint8>),
        int Function(Pointer<Utf8>, Pointer<Uint8>)
      >('lurk_commit');
    final result = lurkCommit(exprPtr, out);
    if (result != 0) {
      throw Exception('Lurk commit failed with error code: $result');
    }
  }

  // int create_proof_ffi(const char* lurk_program, const char* private_params, const char* public_params, size_t max_steps, uint8_t* proof, size_t* proof_len, uint8_t* output_tag, uint8_t* output_val);
  static void _createProof(
    Pointer<Utf8> lurkProgramPtr,
    Pointer<Utf8> privateParamsPtr,
    Pointer<Utf8> publicParamsPtr,
    int maxSteps,
    Pointer<Uint8> proofPtr,
    Pointer<IntPtr> proofLenPtr,
    Pointer<Uint8> outputTagPtr,
    Pointer<Uint8> outputValPtr,
  ) {
    final createProof = getDyLib().lookupFunction<
        Int32 Function(
          Pointer<Utf8>,
          Pointer<Utf8>,
          Pointer<Utf8>,
          IntPtr,
          Pointer<Uint8>,
          Pointer<IntPtr>,
          Pointer<Uint8>,
          Pointer<Uint8>,
        ),
        int Function(
          Pointer<Utf8>,
          Pointer<Utf8>,
          Pointer<Utf8>,
          int,
          Pointer<Uint8>,
          Pointer<IntPtr>,
          Pointer<Uint8>,
          Pointer<Uint8>,
        )
      >('create_proof_ffi');

    final result = createProof(
      lurkProgramPtr,
      privateParamsPtr,
      publicParamsPtr,
      maxSteps,
      proofPtr,
      proofLenPtr,
      outputTagPtr,
      outputValPtr,
    );

    if (result != 0) {
      throw Exception('Proof creation failed with error code: $result');
    }
  }

  // void load_public_params();
  static void _loadPublicParams() {
    final loadPublicParams = getDyLib().lookupFunction<
        Void Function(),
        void Function()
      >('load_public_params');
    loadPublicParams();
  }

  // Public methods

  // int lurk_commit(const char* expr, uint8_t* out);
  static Uint8List lurkCommit(String expr) {
    final exprPtr = expr.toNativeUtf8();
    final outputBuffer = malloc.allocate<Uint8>(OutLen);

    try {
      _lurkCommit(exprPtr, outputBuffer);
      final output = Uint8List.fromList(outputBuffer.asTypedList(OutLen));
      print('IlxdZkBridge.lurkCommit() invoked with no issues');
      return output;
    } finally {
      malloc.free(exprPtr);
      malloc.free(outputBuffer);
    }
  }

  // int create_proof_ffi(const char* lurk_program, const char* private_params, const char* public_params, size_t max_steps, uint8_t* proof, size_t* proof_len, uint8_t* output_tag, uint8_t* output_val);
  static void createProof(
    String lurkProgram,
    String privateParams,
    String publicParams,
    int maxSteps,
    Uint8List proof,
    Uint8List outputTag,
    Uint8List outputVal,
  ) {
    final lurkProgramPtr = lurkProgram.toNativeUtf8();
    final privateParamsPtr = privateParams.toNativeUtf8();
    final publicParamsPtr = publicParams.toNativeUtf8();

    final proofPtr = malloc.allocate<Uint8>(proof.length);
    final outputTagPtr = malloc.allocate<Uint8>(outputTag.length);
    final outputValPtr = malloc.allocate<Uint8>(outputVal.length);
    final proofLenPtr = malloc.allocate<IntPtr>(1);
    proofLenPtr.value = proof.length;

    try {
      _createProof(
        lurkProgramPtr,
        privateParamsPtr,
        publicParamsPtr,
        maxSteps,
        proofPtr,
        proofLenPtr,
        outputTagPtr,
        outputValPtr,
      );

      // Copy the data back to the provided Uint8Lists
      proof.setAll(0, proofPtr.asTypedList(proof.length));
      outputTag.setAll(0, outputTagPtr.asTypedList(outputTag.length));
      outputVal.setAll(0, outputValPtr.asTypedList(outputVal.length));

      print('IlxdZkBridge.createProof() invoked with no issues');
    } finally {
      malloc.free(lurkProgramPtr);
      malloc.free(privateParamsPtr);
      malloc.free(publicParamsPtr);
      malloc.free(proofPtr);
      malloc.free(outputTagPtr);
      malloc.free(outputValPtr);
      malloc.free(proofLenPtr);
    }
  }

  static void loadPublicParams() {
    _loadPublicParams();
    print('IlxdZkBridge.loadPublicParams() invoked with no issues');
  }
}
