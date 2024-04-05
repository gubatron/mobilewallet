// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>

import 'dart:ffi';
import 'dart:typed_data';
import 'package:ilxd_bridge/ilxd_common.dart';
import 'package:ffi/ffi.dart';

class IlxdCryptoBridge {
  static const KeyLen = 32;

  static final DynamicLibrary _dylib = DynamicLibrary.open(IlxdCommon.getLibPath(Library.CRYPTO));

  // void generate_secret_key(uint8_t* out);
  static final _generateSecretKey = _dylib.lookupFunction<Void Function(Pointer<Uint8>), void Function(Pointer<Uint8>)>('generate_secret_key');

  // void secret_key_from_seed(const uint8_t* seed, uint8_t* out);
  static final _secretKeyFromSeed = _dylib.lookupFunction<Void Function(Pointer<Uint8>, Pointer<Uint8>), void Function(Pointer<Uint8>, Pointer<Uint8>)>('secret_key_from_seed');

  // void priv_to_pub(const uint8_t* bytes, uint8_t* out);
  static final _privToPub = _dylib.lookupFunction<Void Function(Pointer<Uint8>, Pointer<Uint8>), void Function(Pointer<Uint8>, Pointer<Uint8>)>('priv_to_pub');

  // void compressed_to_full(const uint8_t* bytes, uint8_t* out_x, uint8_t* out_y);
  static final _compressedToFull = _dylib.lookupFunction<Void Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>), void Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>)>('compressed_to_full');

  // void sign(const uint8_t* privkey, const uint8_t* message_digest, uint8_t* out);
  static final _sign = _dylib.lookupFunction<Void Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>), void Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>)>('sign');

  // bool verify(const uint8_t* pub_bytes, const uint8_t* digest_bytes, const uint8_t* sig_r, const uint8_t* sig_s);
  static final _verify = _dylib.lookupFunction<Bool Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>), bool Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>)>('verify');

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