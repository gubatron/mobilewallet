#!/usr/bin/env bash
# if ILXD_HOME is not set, exit with an error
if [ -z "$ILXD_HOME" ]; then
  echo "ILXD_HOME path not found"
  echo "e.g. export ILXD_HOME=/Users/gubatron/workspace/ilxd"
  echo ""
  echo "If you don't have ilxd try git cloning it into another folder:"
  echo "git clone git@github.com:project-illium/ilxd.git"
  exit 1
fi

# Make sure ILXD_HOME exists
if [ ! -d "${ILXD_HOME}" ]; then
  echo "The folder ${ILXD_HOME} does not exist."
  exit 1
fi

rm_if_exists() {
    if [ -f "$1" ]; then
        rm $1
    fi
}

build_rust_crate_archive() {
    pushd $1
    RUST_TARGET_ARCH=$2
    echo ${PWD}
    rustup target add ${RUST_TARGET_ARCH}
    export MACOSX_DEPLOYMENT_TARGET=10.13
    cargo build --target ${RUST_TARGET_ARCH} --release
    popd
}

# One step build and test for the macos binaries
# All resulting binaries for macos are in mobilewallet/ilxd_bridge/macos

pushd macos
rm *.o
rm *.a
rm *.dylib
rm -fr libillium_zk_objs
rm -fr libillium_crypto_objs
OS_NAME=macos
MAC_OS_VERSION_MIN=10.13
RUST_TARGET_ARCH=aarch64-apple-darwin
ARCH=arm64
# Set the path to the Xcode Developer directory
XCODE_DEV_DIR=$(xcode-select --print-path)
# Set the path to the macOS SDK
MACOS_SDK_PATH=$(xcrun --sdk macosx --show-sdk-path)

rm_if_exists "${ILXD_HOME}/zk/rust/target/${RUST_TARGET_ARCH}/release/libillium_zk.a"
rm_if_exists "${ILXD_HOME}/crypto/rust/target/${RUST_TARGET_ARCH}/release/libillium_crypto.a"

# Build libillium_zk.a
build_rust_crate_archive ${ILXD_HOME}/zk/rust ${RUST_TARGET_ARCH}
# Build libillium_crypto.a
build_rust_crate_archive ${ILXD_HOME}/crypto/rust ${RUST_TARGET_ARCH}

# Copy libillium_zk.a and libillium_crypto.a into our bridge's macos/ folder
cp ${ILXD_HOME}/zk/rust/target/${RUST_TARGET_ARCH}/release/libillium_zk.a .
cp ${ILXD_HOME}/crypto/rust/target/${RUST_TARGET_ARCH}/release/libillium_crypto.a .

# Compile the Objective-C code
clang -c ilxd_zk_bridge.m -o "ilxd_zk_bridge_${OS_NAME}_${ARCH}.o" \
    -arch ${ARCH} \
    -isysroot "${MACOS_SDK_PATH}" \
    -fobjc-arc \
    -fmodules \
    -mmacosx-version-min=${MAC_OS_VERSION_MIN}

clang -c ilxd_crypto_bridge.m -o "ilxd_crypto_bridge_${OS_NAME}_${ARCH}.o" \
    -arch ${ARCH} \
    -isysroot "${MACOS_SDK_PATH}" \
    -fobjc-arc \
    -fmodules \
    -mmacosx-version-min=${MAC_OS_VERSION_MIN}

# Create the shared libraries
clang -dynamiclib -o "libilxd_zk_bridge_${OS_NAME}_${ARCH}.dylib" \
    "ilxd_zk_bridge_${OS_NAME}_${ARCH}.o" \
    ${ILXD_HOME}/zk/rust/target/aarch64-apple-darwin/release/libillium_zk.a \
    -arch ${ARCH} \
    -isysroot "${MACOS_SDK_PATH}" \
    -fobjc-arc \
    -fmodules \
    -mmacosx-version-min=${MAC_OS_VERSION_MIN} \
    -framework Foundation \
    -framework SystemConfiguration \
    -lc++ \
    -Wl,-exported_symbols_list,../zk_symbols.txt

clang -dynamiclib -o "libilxd_crypto_bridge_${OS_NAME}_${ARCH}.dylib" \
    "ilxd_crypto_bridge_${OS_NAME}_${ARCH}.o" \
    ${ILXD_HOME}/crypto/rust/target/aarch64-apple-darwin/release/libillium_crypto.a \
    -arch ${ARCH} \
    -isysroot "${MACOS_SDK_PATH}" \
    -fobjc-arc \
    -fmodules \
    -mmacosx-version-min=${MAC_OS_VERSION_MIN} \
    -framework Foundation \
    -framework SystemConfiguration \
    -lc++ \
    -Wl,-exported_symbols_list,../crypto_symbols.txt
# back to ilxd_bridge/
popd

if [ ! -f "macos/libilxd_zk_bridge_${OS_NAME}_${ARCH}.dylib" ]; then
    echo "Error: libilxd_zk_bridge_${OS_NAME}_${ARCH}.dylib not found"
    exit 1
fi

if [ ! -f "macos/libilxd_crypto_bridge_${OS_NAME}_${ARCH}.dylib" ]; then
    echo "Error: libilxd_crypto_bridge_${OS_NAME}_${ARCH}.dylib not found"
    exit 1
fi

echo "ilxd_bridge/macos:"
ls -l macos/**
echo ""

# Now build the dart component
dart pub get
dart run test/test_macos.dart

