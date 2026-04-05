#!/bin/bash
# Build logos-storage-nim for Android

set -e

# Default values
NDK_ROOT="${NDK_ROOT:-/home/lowkey/Android/sdk/ndk/29.0.14206865}"
HOST_TRIPLE="${HOST_TRIPLE:-aarch64-unknown-linux-android}"
ANDROID_ARCH="${ANDROID_ARCH:-arm64-v8a}"
LOGOS_STORAGE_DIR="${LOGOS_STORAGE_DIR:-logos-storage-nim}"

echo "Building logos-storage-nim for Android..."
echo "NDK_ROOT: $NDK_ROOT"
echo "HOST_TRIPLE: $HOST_TRIPLE"
echo "ANDROID_ARCH: $ANDROID_ARCH"

# Check NDK installation
if [ ! -d "$NDK_ROOT" ]; then
    echo "Error: NDK not found at $NDK_ROOT"
    echo "Set NDK_ROOT environment variable or install Android NDK"
    exit 1
fi

# Check toolchain
NDK_TARGET="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64"
if [ ! -d "$NDK_TARGET" ]; then
    echo "Error: NDK toolchain not found at $NDK_TARGET"
    exit 1
fi

# Set Android compilers
CC="$NDK_TARGET/bin/aarch64-linux-android21-clang"
CXX="$NDK_TARGET/bin/aarch64-linux-android21-clang++"
AR="$NDK_TARGET/bin/llvm-ar"

# Verify compilers exist
for tool in "$CC" "$CXX" "$AR"; do
    if [ ! -f "$tool" ]; then
        echo "Error: Tool not found: $tool"
        exit 1
    fi
done

# Check if logos-storage-nim directory exists
if [ ! -d "$LOGOS_STORAGE_DIR" ]; then
    echo "Error: logos-storage-nim directory not found"
    echo "Clone logos-storage-nim first or set LOGOS_STORAGE_DIR"
    exit 1
fi

# Build environment variables
export STATIC=1
export HOST_TRIPLE="$HOST_TRIPLE"
export CC="$CC"
export CXX="$CXX"
export AR="$AR"

echo "Building with NDK toolchain..."
cd "$LOGOS_STORAGE_DIR"

# Try building libstorage
if command -v make >/dev/null 2>&1; then
    echo "Using Make..."
    make libstorage
else
    echo "Error: make not found"
    exit 1
fi

echo "Android build complete!"
echo "Output should be in Nim cache directory"