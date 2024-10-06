#!/usr/bin/env bash
# Check if running in Docker by checking for Docker-specific files
if [ -f /.dockerenv ]; then
    echo "build_android.sh: Running inside Docker container..."
else
    echo
    echo
    echo "build_android.sh: This script is intended to run inside a Docker container."
    echo
    echo
    echo "build_android.sh: Run './docker_build_android.sh'"
    echo
    echo "build_android.sh: (Builds the docker container if necessary and then runs this script)"
    echo 
    echo
    exit 1
fi

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
if [ "$HOST_OS" = "Linux" ]; then
    PREBUILT_DIR="linux-x86_64"
else
    echo "build_android.sh: ERROR: Unsupported host system: $HOST_OS"
    echo "build_android.sh: Needs linux-x86_64 for adecuate android cross-compile toolset."
    exit 1
fi

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
build_rust_for_android ${ILXD_HOME}/crypto/rust aarch64-linux-android

build_rust_for_android ${ILXD_HOME}/zk/rust armv7-linux-androideabi
build_rust_for_android ${ILXD_HOME}/crypto/rust armv7-linux-androideabi

build_rust_for_android ${ILXD_HOME}/zk/rust i686-linux-android
build_rust_for_android ${ILXD_HOME}/crypto/rust i686-linux-android

build_rust_for_android ${ILXD_HOME}/zk/rust x86_64-linux-android
build_rust_for_android ${ILXD_HOME}/crypto/rust x86_64-linux-android

NDK_TOOLCHAIN_PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/${PREBUILT_DIR}/bin

# Compile individual bridges for Android using the NDK

pushd android
ARCHS=("arm64" "armv7" "x86" "x86_64")
for ARCH in "${ARCHS[@]}"; do
    if [ "$ARCH" = "arm64" ]; then
        TARGET_ARCH="aarch64-linux-android21"
        RUST_TARGET="aarch64-linux-android"
    elif [ "$ARCH" = "armv7" ]; then
        TARGET_ARCH="armv7a-linux-androideabi21"
        RUST_TARGET="armv7-linux-androideabi"
    elif [ "$ARCH" = "x86" ]; then
        TARGET_ARCH="i686-linux-android21"
        RUST_TARGET="i686-linux-android"
    elif [ "$ARCH" = "x86_64" ]; then
        TARGET_ARCH="x86_64-linux-android21"
        RUST_TARGET="x86_64-linux-android"
    fi

    $NDK_TOOLCHAIN_PATH/${TARGET_ARCH}-clang++ -shared -o libilxd_zk_bridge_${ARCH}.so -fPIC ilxd_zk_bridge.cpp \
        ${ILXD_HOME}/zk/rust/target/${RUST_TARGET}/release/libillium_zk.a \
        -lc++

    $NDK_TOOLCHAIN_PATH/${TARGET_ARCH}-clang++ -shared -o libilxd_crypto_bridge_${ARCH}.so -fPIC ilxd_crypto_bridge.cpp \
        ${ILXD_HOME}/crypto/rust/target/${RUST_TARGET}/release/libillium_crypto.a \
        -lc++
done
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
