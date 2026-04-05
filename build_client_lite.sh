#!/bin/bash
# Build client-lite version of logos-storage-nim for Android

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Building client-lite version for Android..."

# Step 1: Apply client-lite patches
echo "Step 1: Applying client-lite patches..."
"$SCRIPT_DIR/apply_client_lite_patches.sh"

# Step 2: Build for Android
echo "Step 2: Building for Android..."
"$SCRIPT_DIR/build_android.sh"

echo "Client-lite Android build complete!"