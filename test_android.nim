# Test basic Android compilation for logos-storage-nim
import os

when defined(android):
    echo("Android compilation test successful!")
    echo("Platform: Android")
    echo("Target architecture: ", hostCPU)
    echo("Target OS: ", hostOS)
    
    # Test basic functionality
    var testInt = 42
    var testString = "Android test string"
    
    echo("Integer test: ", testInt)
    echo("String test: ", testString)
    
    # Test file operations (if supported on Android)
    let currentDir = getCurrentDir()
    echo("Current directory: ", currentDir)
    
else:
    echo("This is designed for Android compilation")
    echo("Compile with: nim c --cpu:arm64 --os:android --d:android test_android.nim")