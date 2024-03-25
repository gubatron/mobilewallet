#!/usr/bin/env bash
# Copyright (c) 2024 Project Illium
# This work is licensed under the terms of the MIT License
# For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>

# Build the ilxd_bridge
pushd ilxd_bridge
./build_macos.sh
#./build_ios.sh
#./build_android.sh
#./build_linux.sh
#./build_windows.sh
popd

# Build the wallet
# dart pub get
# dart compile exe --target-os <entry_point_path>
