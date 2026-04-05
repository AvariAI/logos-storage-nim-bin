#!/bin/bash
# Create client-lite patches for logos-storage-nim

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DIR="$SCRIPT_DIR/patches/client-lite"
REPO_DIR="$SCRIPT_DIR/logos-storage-nim"

echo "Creating client-lite patches..."

# Create patch directory
mkdir -p "$PATCH_DIR"

# Check if repo directory exists
if [ ! -d "$REPO_DIR" ]; then
    echo "Error: Repository directory $REPO_DIR does not exist"
    echo "Clone logos-storage-nim first"
    exit 1
fi

cd "$REPO_DIR"

# Reset to clean state first
echo "Resetting repository to clean state..."
git reset --hard HEAD
git clean -fd

# Create patches for removing upload/REST functionality
echo "Creating upload guard patches..."

# Example: Add client-lite guards to upload request files
for file in library/storage_thread_requests/requests/*upload*.nim; do
    if [ -f "$file" ]; then
        echo "Adding client-lite guards to $(basename "$file")"
        
        # Add guard at the beginning of the file
        sed -i '1i\when not defined(clientLite):' "$file"
        
        # Add disable guard before each procedure/function
        sed -i '/^proc\s\|^func\s\|^method\s/i\when not defined(clientLite):' "$file"
    fi
done

# Create patches for REST API removal
echo "Creating REST API removal patches..."

# Guard REST imports in main files
for file in storage/rest*.nim; do
    if [ -f "$file" ]; then
        echo "Guarding REST file: $(basename "$file")"
        sed -i '1i\when not defined(clientLite):' "$file"
    fi
done

# Generate patches
git add .
git diff HEAD > "$PATCH_DIR/0001-client-lite-guards.patch"

# Reset to clean state
git reset --hard HEAD

echo "Client-lite patches created in $PATCH_DIR"
echo "Apply with: ./apply_client_lite_patches.sh"