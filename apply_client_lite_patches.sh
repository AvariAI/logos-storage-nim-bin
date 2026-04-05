#!/bin/bash
# Apply client-lite patches to logos-storage-nim

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DIR="$SCRIPT_DIR/patches/client-lite"
REPO_DIR="$SCRIPT_DIR/logos-storage-nim"

echo "Applying client-lite patches..."

# Check if patch directory exists
if [ ! -d "$PATCH_DIR" ]; then
    echo "Error: Patch directory $PATCH_DIR does not exist"
    echo "Run create_client_lite_patch.sh first to generate patches"
    exit 1
fi

# Check if repo directory exists
if [ ! -d "$REPO_DIR" ]; then
    echo "Error: Repository directory $REPO_DIR does not exist"
    echo "Clone logos-storage-nim first"
    exit 1
fi

cd "$REPO_DIR"

# Apply patches in order
for patch_file in "$PATCH_DIR"/*.patch; do
    if [ -f "$patch_file" ]; then
        echo "Applying $(basename "$patch_file")..."
        if ! patch -p1 < "$patch_file"; then
            echo "Error: Failed to apply $(basename "$patch_file")"
            exit 1
        fi
    else
        echo "No patch files found in $PATCH_DIR"
        exit 1
    fi
done

echo "All client-lite patches applied successfully!"