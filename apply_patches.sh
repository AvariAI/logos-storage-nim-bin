#!/bin/bash
# Apply all patches to logos-storage-nim

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_ROOT="$SCRIPT_DIR/patches"
REPO_DIR="$SCRIPT_DIR/logos-storage-nim"

echo "Applying patches..."

# Check if patches directory exists
if [ ! -d "$PATCHES_ROOT" ]; then
    echo "Error: Patches directory $PATCHES_ROOT does not exist"
    exit 1
fi

# Check if repo directory exists
if [ ! -d "$REPO_DIR" ]; then
    echo "Error: Repository directory $REPO_DIR does not exist"
    echo "Clone logos-storage-nim first"
    exit 1
fi

cd "$REPO_DIR"

# Apply patches from all subdirectories in order
for patch_dir in "$PATCHES_ROOT"/*; do
    if [ -d "$patch_dir" ]; then
        echo "Applying patches from $(basename "$patch_dir")..."
        
        # Apply patches in alphabetical order
        for patch_file in "$patch_dir"/*.patch; do
            if [ -f "$patch_file" ]; then
                echo "  Applying $(basename "$patch_file")..."
                if ! patch -p1 < "$patch_file"; then
                    echo "  Warning: Failed to apply $(basename "$patch_file") - continuing..."
                fi
            fi
        done
    fi
done

echo "Patch application complete!"