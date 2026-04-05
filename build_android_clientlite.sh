#!/bin/bash
set -e

echo "=== Android CLIENT_LITE Build (SQLite-only, no REST API) ==="

# Android configuration
export ANDROID_NDK_ROOT="/home/lowkey/Android/Sdk/ndk/29.0.14206865"
export CLIENT_LITE=1
export STATIC=1
export HOST_TRIPLE=aarch64-unknown-linux-android

# Android toolchain
NDK_TARGET="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64"
export CC="$NDK_TARGET/bin/aarch64-linux-android21-clang"
export CXX="$NDK_TARGET/bin/aarch64-linux-android21-clang++"
export AR="$NDK_TARGET/bin/llvm-ar"

# PATH for Nim
export PATH="/home/lowkey/.nimble/bin:/home/lowkey/.choosenim/toolchains/nim-2.2.8/bin:$PATH"

echo "Android NDK: $ANDROID_NDK_ROOT"
echo "Host triple: $HOST_TRIPLE"
echo

cd logos-storage-nim

echo "=== Applying CLIENT_LITE patches ==="
cd ..
for patch in patches/client-lite/*.patch; do
  if [[ -f "$patch" && "$patch" != *"0008"* && "$patch" != *"0009"* ]]; then
    echo "  Applying $(basename "$patch")..."
    cd logos-storage-nim
    if patch -p1 -d . < "$patch" 2>/dev/null; then
      echo "  ✓ Applied"
    else
      echo "  ⚠ Failed to apply $(basename "$patch")"
    fi
    cd ..
  fi
done

echo
echo "=== Building Android CLIENT_LITE libstorage ==="

cd logos-storage-nim

# Build with CLIENT_LITE flags
nim c \
  --out:build/libstorage.a \
  --threads:on \
  --app:staticlib \
  --opt:size \
  --noMain \
  --mm:refc \
  --header \
  --d:metrics \
  --nimMainPrefix:libstorage \
  --d:noSignalHandler \
  --d:chronicles_runtime_filtering \
  --d:chronicles_log_level=ERROR \
  --verbosity:1 \
  --hints:off \
  --d:release \
  --d:CLIENT_LITE \
  --d:disable_libbacktrace \
  library/libstorage.nim

echo
echo "✓ Android CLIENT_LITE build complete!"
echo "Output: logos-storage-nim/build/libstorage.a"
echo "Features: SQLite storage, Discv5 P2P, no LevelDB, no REST API"