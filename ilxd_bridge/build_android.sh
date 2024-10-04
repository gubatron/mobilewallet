#!/usr/bin/env bash

if [ -z "$ILXD_HOME" ]; then
  echo "ILXD_HOME path not found"
  echo "e.g. export ILXD_HOME=/Users/gubatron/workspace/ilxd"
  echo ""
  echo "If you don't have ilxd try git cloning it into another folder:"
  echo "git clone git@github.com:project-illium/ilxd.git"
  exit 1
fi

# Check for NDK path
if [ -z "$ANDROID_NDK_HOME" ]; then
  echo "ANDROID_NDK_HOME not set. Please set the NDK path."
  exit 1
fi

# Detect the host system and set the correct NDK prebuilt path
HOST_OS=$(uname)
if [ "$HOST_OS" = "Darwin" ]; then
  PREBUILT_DIR="darwin-x86_64"
elif [ "$HOST_OS" = "Linux" ]; then
  PREBUILT_DIR="linux-x86_64"
else
  echo "build_android.sh: Unsupported host system: $HOST_OS"
  exit 1
fi

set -x

build_rust_for_android() {
    pushd $1
    RUST_TARGET_ARCH=$2
    export CC_aarch64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/aarch64-linux-android21-clang
    export AR_aarch64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/aarch64-linux-android-ar
    export CXX_aarch64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/aarch64-linux-android21-clang++
    export RANLIB_aarch64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/aarch64-linux-android-ranlib

    export CC_armv7_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/armv7a-linux-androideabi21-clang
    export AR_armv7_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/arm-linux-androideabi-ar
    export CXX_armv7_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/armv7a-linux-androideabi21-clang++
    export RANLIB_armv7_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/arm-linux-androideabi-ranlib

    export CC_i686_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/i686-linux-android21-clang
    export AR_i686_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/i686-linux-android-ar
    export CXX_i686_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/i686-linux-android21-clang++
    export RANLIB_i686_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/i686-linux-android-ranlib

    export CC_x86_64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/x86_64-linux-android21-clang
    export AR_x86_64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/x86_64-linux-android-ar
    export CXX_x86_64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/x86_64-linux-android21-clang++
    export RANLIB_x86_64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/x86_64-linux-android-ranlib

    # Set the correct CC, AR, CXX, and RANLIB based on the target
    if [ "$RUST_TARGET_ARCH" = "aarch64-linux-android" ]; then
        export CC=$CC_aarch64_linux_android
        export AR=$AR_aarch64_linux_android
        export CXX=$CXX_aarch64_linux_android
        export RANLIB=$RANLIB_aarch64_linux_android
    elif [ "$RUST_TARGET_ARCH" = "armv7-linux-androideabi" ]; then
        export CC=$CC_armv7_linux_android
        export AR=$AR_armv7_linux_android
        export CXX=$CXX_armv7_linux_android
        export RANLIB=$RANLIB_armv7_linux_android
    elif [ "$RUST_TARGET_ARCH" = "i686-linux-android" ]; then
        export CC=$CC_i686_linux_android
        export AR=$AR_i686_linux_android
        export CXX=$CXX_i686_linux_android
        export RANLIB=$RANLIB_i686_linux_android
    elif [ "$RUST_TARGET_ARCH" = "x86_64-linux-android" ]; then
        export CC=$CC_x86_64_linux_android
        export AR=$AR_x86_64_linux_android
        export CXX=$CXX_x86_64_linux_android
        export RANLIB=$RANLIB_x86_64_linux_android
    else
        echo "Unsupported target: $RUST_TARGET_ARCH"
        exit 1
    fi

    # Set appropriate CFLAGS
    export CFLAGS="--target=$RUST_TARGET_ARCH"

    # Compile Rust code
    rustup target add ${RUST_TARGET_ARCH}
    cargo build --target ${RUST_TARGET_ARCH} --release
    popd
}

# Build Rust libraries for ARM and x86 architectures
build_rust_for_android ${ILXD_HOME}/zk/rust aarch64-linux-android
exit 0
build_rust_for_android ${ILXD_HOME}/crypto/rust aarch64-linux-android

build_rust_for_android ${ILXD_HOME}/zk/rust armv7-linux-androideabi
build_rust_for_android ${ILXD_HOME}/crypto/rust armv7-linux-androideabi

build_rust_for_android ${ILXD_HOME}/zk/rust i686-linux-android
build_rust_for_android ${ILXD_HOME}/crypto/rust i686-linux-android

build_rust_for_android ${ILXD_HOME}/zk/rust x86_64-linux-android
build_rust_for_android ${ILXD_HOME}/crypto/rust x86_64-linux-android

# Get correct NDK toolchain path (for macOS)
NDK_TOOLCHAIN_PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin

# Compile individual bridges for Android using the NDK

pushd android

# ARM64 architecture for ilxd_zk_bridge
$NDK_TOOLCHAIN_PATH/aarch64-linux-android21-clang++ -shared -o libilxd_zk_bridge_arm64.so -fPIC ilxd_zk_bridge.cpp \
    ${ILXD_HOME}/zk/rust/target/aarch64-linux-android/release/libillium_zk.a \
    -lc++

# ARM64 architecture for ilxd_crypto_bridge
$NDK_TOOLCHAIN_PATH/aarch64-linux-android21-clang++ -shared -o libilxd_crypto_bridge_arm64.so -fPIC ilxd_crypto_bridge.cpp \
    ${ILXD_HOME}/crypto/rust/target/aarch64-linux-android/release/libillium_crypto.a \
    -lc++

# ARMv7 architecture for ilxd_zk_bridge
$NDK_TOOLCHAIN_PATH/armv7a-linux-androideabi21-clang++ -shared -o libilxd_zk_bridge_armv7.so -fPIC ilxd_zk_bridge.cpp \
    ${ILXD_HOME}/zk/rust/target/armv7-linux-androideabi/release/libillium_zk.a \
    -lc++

# ARMv7 architecture for ilxd_crypto_bridge
$NDK_TOOLCHAIN_PATH/armv7a-linux-androideabi21-clang++ -shared -o libilxd_crypto_bridge_armv7.so -fPIC ilxd_crypto_bridge.cpp \
    ${ILXD_HOME}/crypto/rust/target/armv7-linux-androideabi/release/libillium_crypto.a \
    -lc++

# x86 architecture for ilxd_zk_bridge
$NDK_TOOLCHAIN_PATH/i686-linux-android21-clang++ -shared -o libilxd_zk_bridge_x86.so -fPIC ilxd_zk_bridge.cpp \
    ${ILXD_HOME}/zk/rust/target/i686-linux-android/release/libillium_zk.a \
    -lc++

# x86 architecture for ilxd_crypto_bridge
$NDK_TOOLCHAIN_PATH/i686-linux-android21-clang++ -shared -o libilxd_crypto_bridge_x86.so -fPIC ilxd_crypto_bridge.cpp \
    ${ILXD_HOME}/crypto/rust/target/i686-linux-android/release/libillium_crypto.a \
    -lc++

# x86_64 architecture for ilxd_zk_bridge
$NDK_TOOLCHAIN_PATH/x86_64-linux-android21-clang++ -shared -o libilxd_zk_bridge_x86_64.so -fPIC ilxd_zk_bridge.cpp \
    ${ILXD_HOME}/zk/rust/target/x86_64-linux-android/release/libillium_zk.a \
    -lc++

# x86_64 architecture for ilxd_crypto_bridge
$NDK_TOOLCHAIN_PATH/x86_64-linux-android21-clang++ -shared -o libilxd_crypto_bridge_x86_64.so -fPIC ilxd_crypto_bridge.cpp \
    ${ILXD_HOME}/crypto/rust/target/x86_64-linux-android/release/libillium_crypto.a \
    -lc++

popd

# Verify the shared libraries for all architectures
if [ ! -f "android/libilxd_zk_bridge_arm64.so" ] || [ ! -f "android/libilxd_crypto_bridge_arm64.so" ]; then
    echo "Error: libilxd_zk_bridge_arm64.so or libilxd_crypto_bridge_arm64.so not found"
    exit 1
fi

if [ ! -f "android/libilxd_zk_bridge_armv7.so" ] || [ ! -f "android/libilxd_crypto_bridge_armv7.so" ]; then
    echo "Error: libilxd_zk_bridge_armv7.so or libilxd_crypto_bridge_armv7.so not found"
    exit 1
fi

if [ ! -f "android/libilxd_zk_bridge_x86.so" ] || [ ! -f "android/libilxd_crypto_bridge_x86.so" ]; then
    echo "Error: libilxd_zk_bridge_x86.so or libilxd_crypto_bridge_x86.so not found"
    exit 1
fi

if [ ! -f "android/libilxd_zk_bridge_x86_64.so" ] || [ ! -f "android/libilxd_crypto_bridge_x86_64.so" ]; then
    echo "Error: libilxd_zk_bridge_x86_64.so or libilxd_crypto_bridge_x86_64.so not found"
    exit 1
fi

echo "ilxd_bridge/android:"
ls -l android/*
