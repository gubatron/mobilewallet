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

build_rust_library_for_android() {
    pushd $1
    export RUST_TARGET_ARCH=$2

    # Set appropriate toolchain paths for Android architectures
    if [[ "$RUST_TARGET_ARCH" == "i686-linux-android" || "$RUST_TARGET_ARCH" == "armv7-linux-androideabi" ]]; then
        export CFLAGS="-m32 --target=$RUST_TARGET_ARCH"
        export LDFLAGS="-m32"
    else
        export CFLAGS="--target=$RUST_TARGET_ARCH"
        export LDFLAGS=""
    fi

    # NDK toolchains for different architectures
    export CC_aarch64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/aarch64-linux-android27-clang
    export AR_aarch64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/llvm-ar
    export CXX_aarch64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/aarch64-linux-android27-clang++
    export RANLIB_aarch64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/llvm-ranlib

    export CC_armv7_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/armv7a-linux-androideabi27-clang
    export AR_armv7_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/llvm-ar
    export CXX_armv7_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/armv7a-linux-androideabi27-clang++
    export RANLIB_armv7_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/llvm-ranlib

    export CC_i686_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/i686-linux-android27-clang
    export AR_i686_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/llvm-ar
    export CXX_i686_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/i686-linux-android27-clang++
    export RANLIB_i686_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/llvm-ranlib

    export CC_x86_64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/x86_64-linux-android27-clang
    export AR_x86_64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/llvm-ar
    export CXX_x86_64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/x86_64-linux-android27-clang++
    export RANLIB_x86_64_linux_android=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$PREBUILT_DIR/bin/llvm-ranlib

    export RUSTFLAGS="-C link-arg=-v"
    
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

    # Ensure blst can locate the correct compiler for each target
    export TARGET_CC=$CC
    export TARGET_AR=$AR

    # Compile Rust code
    rustup target add ${RUST_TARGET_ARCH}
    cargo build --target ${RUST_TARGET_ARCH} --release
    popd
}

# Function to build Dart bridges for each architecture
build_dart_bridge() {
    local LIB_NAME=$1   # Name of the library (crypto or zk)
    local CPP_FILE=$2   # Name of the CPP file to compile (e.g., ilxd_crypto_bridge.cpp)
    local LIB_FILE=$3   # Name of the Rust static library (e.g., libillium_crypto.a)
    local ARCH=$4       # Target architecture (arm64, armv7, x86, x86_64)
    local TARGET_ARCH=$5 # Android NDK target architecture (e.g., aarch64-linux-android27)
    local RUST_TARGET=$6 # Rust target architecture (e.g., aarch64-linux-android)

    if [ -f ${ILXD_HOME}/${LIB_NAME}/rust/target/${RUST_TARGET}/release/${LIB_FILE} ]; then
        echo "build_android.sh: Building ${CPP_FILE} for ${ARCH}..."
        if [ -f libilxd_${LIB_NAME}_bridge_${ARCH}.so ]; then
            rm libilxd_${LIB_NAME}_bridge_${ARCH}.so
        fi

        $NDK_TOOLCHAIN_PATH/${TARGET_ARCH}-clang++ -shared -o libilxd_${LIB_NAME}_bridge_${ARCH}.so -fPIC ${CPP_FILE} \
            ${ILXD_HOME}/${LIB_NAME}/rust/target/${RUST_TARGET}/release/${LIB_FILE} \
            -lc++
    else
        echo "build_android.sh: ${ILXD_HOME}/${LIB_NAME}/rust/target/${RUST_TARGET}/release/${LIB_FILE} missing, can't build libilxd_${LIB_NAME}_bridge_${ARCH}.so"
    fi
}

# Default flags
BUILD_CRYPTO=true
BUILD_ZK=true

# Argument parsing
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --zk-only) BUILD_CRYPTO=false; BUILD_ZK=true ;;
        --crypto-only) BUILD_CRYPTO=true; BUILD_ZK=false ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Build Rust libraries for ARM and x86 architectures

# ilxd_crypto libraries
if [ "$BUILD_CRYPTO" = true ]; then
    build_rust_library_for_android ${ILXD_HOME}/crypto/rust aarch64-linux-android
    build_rust_library_for_android ${ILXD_HOME}/crypto/rust armv7-linux-androideabi
    build_rust_library_for_android ${ILXD_HOME}/crypto/rust i686-linux-android
    build_rust_library_for_android ${ILXD_HOME}/crypto/rust x86_64-linux-android
fi

# ilxd_zk libraries
if [ "$BUILD_ZK" = true ]; then
    build_rust_library_for_android ${ILXD_HOME}/zk/rust aarch64-linux-android
    build_rust_library_for_android ${ILXD_HOME}/zk/rust armv7-linux-androideabi
    build_rust_library_for_android ${ILXD_HOME}/zk/rust i686-linux-android
    build_rust_library_for_android ${ILXD_HOME}/zk/rust x86_64-linux-android
fi

NDK_TOOLCHAIN_PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/${PREBUILT_DIR}/bin

# Compile individual bridges for Android using the NDK

pushd android
ARCHS=("arm64" "armv7" "x86" "x86_64")
for ARCH in "${ARCHS[@]}"; do
    if [ "$ARCH" = "arm64" ]; then
        TARGET_ARCH="aarch64-linux-android27"
        RUST_TARGET="aarch64-linux-android"
    elif [ "$ARCH" = "armv7" ]; then
        TARGET_ARCH="armv7a-linux-androideabi21"
        RUST_TARGET="armv7-linux-androideabi"
    elif [ "$ARCH" = "x86" ]; then
        TARGET_ARCH="i686-linux-android27"
        RUST_TARGET="i686-linux-android"
    elif [ "$ARCH" = "x86_64" ]; then
        TARGET_ARCH="x86_64-linux-android27"
        RUST_TARGET="x86_64-linux-android"
    fi

    # Build crypto bridge if requested
    if [ "$BUILD_CRYPTO" = true ]; then
        build_dart_bridge "crypto" "ilxd_crypto_bridge.cpp" "libillium_crypto.a" "$ARCH" "$TARGET_ARCH" "$RUST_TARGET"
    fi

    # Build zk bridge if requested
    if [ "$BUILD_ZK" = true ]; then
        build_dart_bridge "zk" "ilxd_zk_bridge.cpp" "libillium_zk.a" "$ARCH" "$TARGET_ARCH" "$RUST_TARGET"
    fi    
done
popd

# Verify the shared libraries for all architectures

if [ "$BUILD_CRYPTO" = true ]; then
    # First, check all libilxd_crypto_* versions
    if [ ! -f "android/libilxd_crypto_bridge_arm64.so" ]; then
        echo "Error: libilxd_crypto_bridge_arm64.so not found"
    else
        echo "Success: libilxd_crypto_bridge_arm64.so found"
    fi

    if [ ! -f "android/libilxd_crypto_bridge_armv7.so" ]; then
        echo "Error: libilxd_crypto_bridge_armv7.so not found"
    else
        echo "Success: libilxd_crypto_bridge_armv7.so found"
    fi

    if [ ! -f "android/libilxd_crypto_bridge_x86.so" ]; then
        echo "Error: libilxd_crypto_bridge_x86.so not found"
    else
        echo "Success: libilxd_crypto_bridge_x86.so found"
    fi

    if [ ! -f "android/libilxd_crypto_bridge_x86_64.so" ]; then
        echo "Error: libilxd_crypto_bridge_x86_64.so not found"
    else
        echo "Success: libilxd_crypto_bridge_x86_64.so found"
    fi
fi

if [ "$BUILD_ZK" = true ]; then
    # Now, check all libilxd_zk_bridge_* versions
    if [ ! -f "android/libilxd_zk_bridge_arm64.so" ]; then
        echo "Error: libilxd_zk_bridge_arm64.so not found"
    else
	echo "Success: libilxd_zk_bridge_arm64.so found"
    fi

    if [ ! -f "android/libilxd_zk_bridge_armv7.so" ]; then
        echo "Error: libilxd_zk_bridge_armv7.so not found"
    else
	echo "Success: libilxd_zk_bridge_armv7.so found"
    fi

    if [ ! -f "android/libilxd_zk_bridge_x86.so" ]; then
        echo "Error: libilxd_zk_bridge_x86.so not found"
    else
	echo "Success: libilxd_zk_bridge_x86 found"
    fi

    if [ ! -f "android/libilxd_zk_bridge_x86_64.so" ]; then
        echo "Error: libilxd_zk_bridge_x86_64.so not found"
    else
	echo "Success: libilxd_zk_bridge_x86_64 found"
    fi
fi

echo "ilxd_bridge/android:"
ls -l android/*
