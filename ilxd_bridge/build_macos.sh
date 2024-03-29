#!/usr/bin/env bash

# One step build and test for the macos binaries
# All resulting binaries for macos are in mobilewallet/ilxd_bridge/macos

pushd macos/Classes
OS_NAME=macos
MAC_OS_VERSION_MIN=10.13
RUST_TARGET_ARCH=aarch64-apple-darwin
# Set the path to the Xcode Developer directory
XCODE_DEV_DIR=$(xcode-select --print-path)

# Set the path to the macOS SDK
MACOS_SDK_PATH=$(xcrun --sdk macosx --show-sdk-path)

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
if [ ! -d "$ILXD_HOME" ]; then
  echo "The folder $ILXD_HOME does not exist."
  exit 1 # Exits the script with a status of 1 indicating an error.
fi

# Remove any previous build of libillium_zk
if [ -f "${ILXD_HOME}/zk/rust/target/${RUST_TARGET_ARCH}/release/libillium_zk.a" ]; then
  rm -f ${ILXD_HOME}/zk/rust/target/${RUST_TARGET_ARCH}/release/libillium_zk.*
fi

# Build libillium_zk.a
pushd ${ILXD_HOME}/zk/rust
rustup target add aarch64-apple-darwin
export MACOSX_DEPLOYMENT_TARGET=10.13
# this should ideally set mmacosx-version-min=10.13 in the rust static libraries
cargo build --target ${RUST_TARGET_ARCH} --release
popd

# Copy libillium_zk.a into our bridge's macos/ folder
cp ${ILXD_HOME}/zk/rust/target/${RUST_TARGET_ARCH}/release/libillium_zk.a ..

# Set the Objective-C shared library target architecture
ARCHS=("arm64")

# Compile the Objective-C code and create the shared library for each architecture
for ARCH in "${ARCHS[@]}"
do
  # Compile the Objective-C code
  clang -c IlxdBridge.m -o "IlxdBridge_${OS_NAME}_${ARCH}.o" \
      -arch ${ARCH} \
      -isysroot "${MACOS_SDK_PATH}" \
      -fobjc-arc \
      -fmodules \
      -mmacosx-version-min=${MAC_OS_VERSION_MIN}

  # Create the shared library
  clang -dynamiclib -o "libilxd_bridge_${OS_NAME}_${ARCH}.dylib" \
      "IlxdBridge_${OS_NAME}_${ARCH}.o" \
      ${ILXD_HOME}/zk/rust/target/aarch64-apple-darwin/release/libillium_zk.a \
      -arch ${ARCH} \
      -isysroot "${MACOS_SDK_PATH}" \
      -fobjc-arc \
      -fmodules \
      -mmacosx-version-min=${MAC_OS_VERSION_MIN} \
      -framework Foundation \
      -lc++

  # If previous versions of the libraries exist, remove them
  if [ -f "../libilxd_bridge_${OS_NAME}_${ARCH}.dylib" ]; then
    rm ../libilxd_bridge_${OS_NAME}_${ARCH}.dylib
  fi

  if [ -f "../IlxdBridge_${ARCH}.o" ]; then
    rm ../IlxdBridge_${OS_NAME}_${ARCH}.o
  fi

  mv libilxd_bridge_${OS_NAME}_${ARCH}.dylib .. && echo "Shared library built successfully: libilxd_bridge_${OS_NAME}_${ARCH}.dylib, moved to ../ -> ilxd_bridge/macos"
  mv IlxdBridge_${OS_NAME}_${ARCH}.o .. && echo "Also moved IlxdBridge_${OS_NAME}_${ARCH}.o to ../ -> ilxd_bridge/macos"
done

popd

echo "./macos contents..."
ls -l macos/**
echo ""

# Now build the dart component
dart pub get
dart run test/test_macos.dart
