#!/usr/bin/env bash
# Check if running inside Docker by checking for the .dockerenv file
if [ -f /.dockerenv ]; then
    echo "docker_build_image.sh: This script should not be run inside a Docker container."
    exit 1
fi

# Parse command-line arguments
REBUILD_IMAGE=false
for arg in "$@"
do
    if [ "$arg" == "--rebuild-image" ]; then
        REBUILD_IMAGE=true
    fi
done

# Check if the Docker image 'ilxd_bridge_android_builder' exists
if [[ "$REBUILD_IMAGE" == "true" || "$(docker images -q ilxd_bridge_android_builder 2>/dev/null)" == "" ]]; then
    echo "docker_build_android.sh: ilxd_bridge_android_builder image not found. Building the image..."
    docker build -t ilxd_bridge_android_builder .
else
    echo "docker_build_android.sh: ilxd_bridge_android_builder image already exists. Skipping build."
fi

# Run the Docker container
docker run --rm -it \
    -v ${PWD}:/workspace/mobilewallet/ilxd_bridge \
    ilxd_bridge_android_builder \
    /bin/bash -c "cd /workspace/mobilewallet/ilxd_bridge && ./build_android.sh"

