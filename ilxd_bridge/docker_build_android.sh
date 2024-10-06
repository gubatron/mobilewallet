#!/usr/bin/env bash
# Check if running inside Docker by checking for the .dockerenv file
if [ -f /.dockerenv ]; then
    echo "docker_build_image.sh: This script should not be run inside a Docker container."
    exit 1
fi

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

# Run the Docker container
docker run --rm -it \
    -v ${PWD}:/workspace/mobilewallet/ilxd_bridge \
    -v ${ILXD_HOME}:/workspace/ilxd \
    ilxd_bridge_android_builder
