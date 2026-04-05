"""Fixed Android build function with proper order."""

import subprocess

from src.utils import run_command
from src.repository import apply_patches


def build_libstorage_android_fixed(logos_storage_dir, jobs: int, patch_dir) -> None:
    """Build client-lite libstorage for Android ARM64.
    
    Args:
        logos_storage_dir: Path to the logos-storage-nim repository
        jobs: Number of parallel build jobs
        patch_dir: Path to patches directory
    """
    print("Building client-lite libstorage for Android ARM64...")
    
    # Configure Android build environment
    from src.utils import configure_android_environment
    android_env = configure_android_environment()
    
    print(f"Android NDK root: {android_env['CC'].split('/bin')[0]}/..")
    print(f"Host triple: {android_env['HOST_TRIPLE']}")
    
    # Initialize submodules FIRST (before applying patches)
    print("Initializing Android git submodules...")
    try:
        # Initialize and update submodules manually to avoid bundled Nim build
        run_command([
            "git", "-C", str(logos_storage_dir), "submodule", "update", "--init", "--recursive"
        ], env=android_env)
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to initialize git submodules for Android")
        print(f"Command: {' '.join(e.cmd)}")
        print(f"Exit code: {e.returncode}")
        if e.stdout:
            print(f"STDOUT:\n{e.stdout}")
        if e.stderr:
            print(f"STDERR:\n{e.stderr}")
        raise

    # Apply client-lite patches AFTER submodules are initialized
    print("Applying client-lite patches after submodule initialization...")
    apply_patches(logos_storage_dir, patch_dir)
    
    # Build with parallel jobs and Android environment
    print(f"Building Android libstorage with {jobs} parallel jobs...")
    try:
        # Add CLIENT_LITE flag for client-lite mode and use system Nim for Android
        android_env["CLIENT_LITE"] = "1"
        build_cmd = ["make", "-j", str(jobs), "-C", str(logos_storage_dir), "libstorage", "USE_SYSTEM_NIM=1"]
        run_command(build_cmd, env=android_env)
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to build Android libstorage")
        print(f"Command: {' '.join(e.cmd)}")
        print(f"Exit code: {e.returncode}")
        if e.stdout:
            print(f"STDOUT:\n{e.stdout}")
        if e.stderr:
            print(f"STDERR:\n{e.stderr}")
        raise
    
    print("Android libstorage build complete")