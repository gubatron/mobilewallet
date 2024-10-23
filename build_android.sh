#!/usr/bin/env bash
# Copyright (c) 2024 Project Illium
# This work is licensed under the terms of the MIT License
# For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>

# Build the ilxd_bridge, builds the android binaries for all architectures in Linux Ubuntu over Docker
# which has all the necessary tooling for cross builds

# The invoked script will make sure it builds the image and then issue the right build script
# which will only allow itselof to be run from Docker,.
pushd ilxd_bridge
./docker_build_android.sh
popd

# Build the wallet
# dart pub get
# dart compile exe --target-os <entry_point_path>
