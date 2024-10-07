// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>

import 'dart:ffi';
import 'dart:typed_data';
import 'package:ilxd_bridge/ilxd_common.dart';
import 'package:ffi/ffi.dart';

class IlxdCryptoBridge {
  static const KeyLen = 32;

  static DynamicLibrary? _dylib;

  // Method to get the DynamicLibrary, ensures lazy initialization
  static DynamicLibrary getDyLib() {
      final libPath = IlxdCommon.getLibPath(Library.CRYPTO);
      print('Loading dynamic library from path: $libPath');
      if (libPath.isEmpty) {
         throw Exception('Dynamic library path is empty. Cannot load the library.');
      }
      if (_dylib == null) {
          _dylib = DynamicLibrary.open(libPath);
      }
      return _dylib!;
  }

    
  // generate_secret_key function lookup happens inside the method
  static void _generateSecretKey(Pointer<Uint8> out) {
    final generateSecretKey = getDyLib().lookupFunction<Void Function(Pointer<Uint8>), void Function(Pointer<Uint8>)>('generate_secret_key');
    generateSecretKey(out);
  }

  // secret_key_from_seed function lookup happens inside the method
  static void _secretKeyFromSeed(Pointer<Uint8> seed, Pointer<Uint8> out) {
    final secretKeyFromSeed = getDyLib().lookupFunction<Void Function(Pointer<Uint8>, Pointer<Uint8>), void Function(Pointer<Uint8>, Pointer<Uint8>)>('secret_key_from_seed');
    secretKeyFromSeed(seed, out);
  }

  // priv_to_pub function lookup happens inside the method
  static void _privToPub(Pointer<Uint8> privKey, Pointer<Uint8> out) {
    final privToPub = getDyLib().lookupFunction<Void Function(Pointer<Uint8>, Pointer<Uint8>), void Function(Pointer<Uint8>, Pointer<Uint8>)>('priv_to_pub');
    privToPub(privKey, out);
  }

  // compressed_to_full function lookup happens inside the method
  static void _compressedToFull(Pointer<Uint8> compressed, Pointer<Uint8> outX, Pointer<Uint8> outY) {
    final compressedToFull = getDyLib().lookupFunction<Void Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>), void Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>)>('compressed_to_full');
    compressedToFull(compressed, outX, outY);
  }

  // sign function lookup happens inside the method
  static void _sign(Pointer<Uint8> privKey, Pointer<Uint8> messageDigest, Pointer<Uint8> out) {
    final sign = getDyLib().lookupFunction<Void Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>), void Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>)>('sign');
    sign(privKey, messageDigest, out);
  }

  // verify function lookup happens inside the method
  static bool _verify(Pointer<Uint8> pubBytes, Pointer<Uint8> digestBytes, Pointer<Uint8> sigR, Pointer<Uint8> sigS) {
    final verify = getDyLib().lookupFunction<Bool Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>), bool Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>)>('verify');
    return verify(pubBytes, digestBytes, sigR, sigS);
  }

  static Uint8List generateSecretKey() {
    final outputBuffer = malloc.allocate<Uint8>(KeyLen);

    try {
      _generateSecretKey(outputBuffer);
      final output = Uint8List.fromList(outputBuffer.asTypedList(KeyLen));
      print('IlxdCryptoBridge.generateSecretKey() invoked with no issues');
      return output;
    } finally {
      malloc.free(outputBuffer);
    }
  }

  static Uint8List secretKeyFromSeed(Uint8List seed) {
    final seedPtr = malloc.allocate<Uint8>(KeyLen);
    final outputBuffer = malloc.allocate<Uint8>(KeyLen);

    try {
      seedPtr.asTypedList(KeyLen).setAll(0, seed);
      _secretKeyFromSeed(seedPtr, outputBuffer);
      final output = Uint8List.fromList(outputBuffer.asTypedList(KeyLen));
      print('IlxdCryptoBridge.secretKeyFromSeed(...) invoked with no issues');
      return output;
    } finally {
      malloc.free(seedPtr);
      malloc.free(outputBuffer);
    }
  }

  static Uint8List privToPub(Uint8List privKey) {
    final privKeyPtr = malloc.allocate<Uint8>(KeyLen);
    final outputBuffer = malloc.allocate<Uint8>(KeyLen);

    try {
      privKeyPtr.asTypedList(KeyLen).setAll(0, privKey);
      _privToPub(privKeyPtr, outputBuffer);
      final output = Uint8List.fromList(outputBuffer.asTypedList(KeyLen));
      print('IlxdCryptoBridge.privToPub(...) invoked with no issues');
      return output;
    } finally {
      malloc.free(privKeyPtr);
      malloc.free(outputBuffer);
    }
  }

  static void compressedToFull(Uint8List compressed, Uint8List outX, Uint8List outY) {
    final compressedPtr = malloc.allocate<Uint8>(KeyLen);
    final outXPtr = malloc.allocate<Uint8>(KeyLen);
    final outYPtr = malloc.allocate<Uint8>(KeyLen);

    try {
      compressedPtr.asTypedList(KeyLen).setAll(0, compressed);
      _compressedToFull(compressedPtr, outXPtr, outYPtr);
      outX.setAll(0, outXPtr.asTypedList(KeyLen));
      outY.setAll(0, outYPtr.asTypedList(KeyLen));
      print('IlxdCryptoBridge.compressedToFull(...) invoked with no issues');
    } finally {
      malloc.free(compressedPtr);
      malloc.free(outXPtr);
      malloc.free(outYPtr);
    }
  }

  static Uint8List sign(Uint8List privKey, Uint8List messageDigest) {
    final privKeyPtr = malloc.allocate<Uint8>(KeyLen);
    final messageDigestPtr = malloc.allocate<Uint8>(KeyLen);
    final outputBuffer = malloc.allocate<Uint8>(64);

    try {
      privKeyPtr.asTypedList(KeyLen).setAll(0, privKey);
      messageDigestPtr.asTypedList(KeyLen).setAll(0, messageDigest);
      _sign(privKeyPtr, messageDigestPtr, outputBuffer);
      final output = Uint8List.fromList(outputBuffer.asTypedList(64));
      print('IlxdCryptoBridge.sign(...) invoked with no issues');
      return output;
    } finally {
      malloc.free(privKeyPtr);
      malloc.free(messageDigestPtr);
      malloc.free(outputBuffer);
    }
  }

  static bool verify(Uint8List pubBytes, Uint8List digestBytes, Uint8List sigR, Uint8List sigS) {
    final pubBytesPtr = malloc.allocate<Uint8>(KeyLen);
    final digestBytesPtr = malloc.allocate<Uint8>(KeyLen);
    final sigRPtr = malloc.allocate<Uint8>(KeyLen);
    final sigSPtr = malloc.allocate<Uint8>(KeyLen);

    try {
      pubBytesPtr.asTypedList(KeyLen).setAll(0, pubBytes);
      digestBytesPtr.asTypedList(KeyLen).setAll(0, digestBytes);
      sigRPtr.asTypedList(KeyLen).setAll(0, sigR);
      sigSPtr.asTypedList(KeyLen).setAll(0, sigS);
      final result = _verify(pubBytesPtr, digestBytesPtr, sigRPtr, sigSPtr);
      print('IlxdCryptoBridge.verify(...) invoked with no issues');
      return result;
    } finally {
      malloc.free(pubBytesPtr);
      malloc.free(digestBytesPtr);
      malloc.free(sigRPtr);
      malloc.free(sigSPtr);
    }
  }
}
