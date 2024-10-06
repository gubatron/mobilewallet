#!/usr/bin/env bash
# Check if the Docker image 'ilxd_bridge_android_builder' exists
if [[ "$(docker images -q ilxd_bridge_android_builder 2>/dev/null)" == "" ]]; then
    echo "docker_build_android.sh: ilxd_bridge_android_builder image not found. Building the image..."
    docker build -t ilxd_bridge_android_builder .
else
    echo "docker_build_android.sh: ilxd_bridge_android_builder image already exists. Skipping build."
fi

# Check if ILXD_HOME is set and exists
if [ -z "$ILXD_HOME" ]; then
    echo "docker_build_android.sh: Error: ILXD_HOME environment variable is not set."
    exit 1
elif [ ! -d "$ILXD_HOME" ]; then
    echo "docker_build_android.sh: Error: ILXD_HOME directory does not exist."
    exit 1
fi

# Check if ANDROID_NDK_HOME is set and exists
if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "docker_build_android.sh: Error: ANDROID_NDK_HOME environment variable is not set."
    exit 1
elif [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "docker_build_android.sh: Error: ANDROID_NDK_HOME directory does not exist."
    exit 1
fi

# Run the Docker container
docker run --rm -it \
    -v ${ILXD_HOME}:/workspace/ilxd \
    -v ${ANDROID_NDK_HOME}:/workspace/android-ndk \
    -e ILXD_HOME=/workspace/ilxd \
    -e ANDROID_NDK_HOME=/workspace/android-ndk \
    ilxd_bridge_android_builder
