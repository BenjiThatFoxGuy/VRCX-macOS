#!/bin/bash

# Build script for macOS Electron version of VRCX (x64 only)
# Based on the solution from GitHub issue vrcx-team/VRCX#1117

set -e

echo "Building VRCX for macOS (x64)..."

# Set DOTNET_ROOT for x64 builds on Apple Silicon
export DOTNET_ROOT=/usr/local/share/dotnet/x64

# Change to project root directory
cd "$(dirname "$0")/.."

# Check for .NET availability - try x64 first, fall back to system dotnet
DOTNET_CMD="/usr/local/share/dotnet/x64/dotnet"
if [[ ! -f "$DOTNET_CMD" ]]; then
    echo "x64 .NET SDK not found at /usr/local/share/dotnet/x64/, trying system dotnet..."
    DOTNET_CMD="dotnet"
    if ! command -v dotnet &> /dev/null; then
        echo "Error: No .NET SDK found. Please install .NET 9.0 SDK."
        exit 1
    fi
fi

# Check .NET version
echo "Checking .NET version..."
$DOTNET_CMD --version

# Patch package version
echo "Patching package version..."
node src-electron/patch-package-version.js

# Build the .NET part
echo "Building .NET Electron project..."
$DOTNET_CMD build Dotnet/VRCX-Electron.csproj -c Release -a x64 -v detailed

# Install npm dependencies
echo "Installing npm dependencies..."
npm install --arch=x64

# Build the web assets
echo "Building web assets..."
npm run prod-linux --arch=x64

# Build the Electron app
echo "Building Electron app..."
./node_modules/.bin/electron-builder --mac --x64 -c.mac.minimumSystemVersion=10.15.0 -c.mac.target=dir -c.mac.identity=null -c.mac.category=public.app-category.utilities

# Optional: Sign the app bundle (requires developer certificate)
if [[ -n "$CODESIGN_IDENTITY" ]]; then
    echo "Signing app bundle..."
    codesign --sign "$CODESIGN_IDENTITY" --deep build/mac/VRCX.app/
else
    echo "Signing app bundle with ad-hoc signature..."
    codesign --sign - --deep build/mac/VRCX.app/
fi

echo "Build completed successfully!"
echo "App bundle location: build/mac/VRCX.app/"