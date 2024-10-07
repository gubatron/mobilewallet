# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get install -y unzip
RUN apt-get install -y zip
RUN apt-get install -y libssl-dev
RUN apt-get install -y pkg-config
RUN apt-get install -y clang
RUN apt-get install -y cmake
RUN apt-get install -y ninja-build
RUN apt-get install -y python3
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y wget
RUN apt-get install -y libgl1-mesa-dev
RUN apt-get install -y clang gcc
RUN apt-get install -y gcc-multilib g++-multilib
RUN apt-get install -y emacs-nox

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Add Rust to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Add Android targets to Rust
RUN rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi \
    i686-linux-android \
    x86_64-linux-android

# Install cargo-ndk (optional, simplifies cross-compilation)
RUN cargo install cargo-ndk

# Install Dart SDK (if necessary)
RUN wget https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
RUN unzip dartsdk-linux-x64-release.zip -d /usr/lib
ENV PATH="$PATH:/usr/lib/dart/bin"

RUN mkdir -p /workspace
ENV ILXD_HOME=/workspace/ilxd


# Install Android NDK r27b
RUN wget https://dl.google.com/android/repository/android-ndk-r27b-linux.zip -O android-ndk-r27b.zip
RUN unzip android-ndk-r27b.zip -d /workspace
RUN ln -s /workspace/android-ndk-r27b /workspace/android-ndk
ENV ANDROID_NDK_HOME=/workspace/android-ndk
ENV PATH="$PATH:${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin"

# git clone ilxd to /workspace/ilxd
# RUN git clone https://github.com/project-illium/ilxd.git /workspace/ilxd
# Clone the specific branch from the ilxd repository that has some dependency upgrades to /workspace/ilxd
RUN git clone --branch dep-fix-blst-0.3.13 https://github.com/gubatron/ilxd.git /workspace/ilxd

WORKDIR /workspace/mobilewallet/ilxd_bridge

# Set the entry point
CMD ["bash"]

# Set build_android.sh as the entrypoint
#ENTRYPOINT ["./build_android.sh"]