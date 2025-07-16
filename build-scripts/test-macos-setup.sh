#!/bin/bash

# Test script to validate the macOS build setup without requiring .NET 9.0
# This ensures the build infrastructure is correctly configured

set -e

echo "Testing macOS build setup for VRCX..."

# Change to project root directory
cd "$(dirname "$0")/.."

# Check if the main configuration files exist
echo "Checking configuration files..."
if [[ ! -f "package.json" ]]; then
    echo "Error: package.json not found"
    exit 1
fi

if [[ ! -f "src-electron/main.js" ]]; then
    echo "Error: src-electron/main.js not found"
    exit 1
fi

if [[ ! -f "Dotnet/VRCX-Electron.csproj" ]]; then
    echo "Error: Dotnet/VRCX-Electron.csproj not found"
    exit 1
fi

echo "✓ Configuration files exist"

# Check for macOS-specific entries in package.json
echo "Checking package.json for macOS support..."
if grep -q "build-electron-mac" package.json; then
    echo "✓ build-electron-mac script found"
else
    echo "Error: build-electron-mac script not found in package.json"
    exit 1
fi

if grep -q "build-macos" package.json; then
    echo "✓ build-macos script found"
else
    echo "Error: build-macos script not found in package.json"
    exit 1
fi

if grep -q '"mac"' package.json; then
    echo "✓ macOS build configuration found"
else
    echo "Error: macOS build configuration not found in package.json"
    exit 1
fi

# Check for DOTNET_ROOT handling in main.js
echo "Checking main.js for macOS DOTNET_ROOT handling..."
if grep -q "process.platform === 'darwin'" src-electron/main.js; then
    echo "✓ macOS platform detection found"
else
    echo "Error: macOS platform detection not found in main.js"
    exit 1
fi

if grep -q "DOTNET_ROOT.*x64" src-electron/main.js; then
    echo "✓ DOTNET_ROOT x64 configuration found"
else
    echo "Error: DOTNET_ROOT x64 configuration not found in main.js"
    exit 1
fi

# Check for SQLite libraries
echo "Checking for SQLite libraries..."
if [[ -f "Dotnet/libs/macos/SQLite.Interop.dll" ]]; then
    echo "✓ macOS SQLite.Interop.dll found"
else
    echo "Error: macOS SQLite.Interop.dll not found"
    exit 1
fi

# Check for macOS-specific entries in csproj
echo "Checking VRCX-Electron.csproj for macOS support..."
if grep -q "OSX" Dotnet/VRCX-Electron.csproj; then
    echo "✓ macOS conditional compilation found"
else
    echo "Error: macOS conditional compilation not found in csproj"
    exit 1
fi

# Check web assets can be built
echo "Testing web asset build..."
if command -v npm &> /dev/null; then
    echo "✓ npm available"
    if npm run prod-linux > /dev/null 2>&1; then
        echo "✓ Web assets build successfully"
    else
        echo "Error: Web assets build failed"
        exit 1
    fi
else
    echo "Warning: npm not available, skipping web asset build test"
fi

# Test version patching
echo "Testing version patching..."
if node src-electron/patch-package-version.js > /dev/null 2>&1; then
    echo "✓ Version patching works"
else
    echo "Error: Version patching failed"
    exit 1
fi

# Check build script is executable
echo "Checking build script..."
if [[ -x "build-scripts/build-macos.sh" ]]; then
    echo "✓ build-macos.sh is executable"
else
    echo "Error: build-macos.sh is not executable"
    exit 1
fi

# Check documentation exists
echo "Checking documentation..."
if [[ -f "README.macOS.md" ]]; then
    echo "✓ macOS documentation found"
else
    echo "Error: macOS documentation not found"
    exit 1
fi

echo ""
echo "All tests passed! ✓"
echo "The macOS build setup is correctly configured."
echo ""
echo "To build VRCX for macOS, ensure you have:"
echo "1. .NET 9.0 SDK (x64 version) installed"
echo "2. Node.js 18+ installed"
echo "3. Xcode Command Line Tools installed"
echo ""
echo "Then run: npm run build-macos"