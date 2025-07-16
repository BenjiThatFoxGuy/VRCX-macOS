#!/bin/bash

# Build script for macOS Electron version of VRCX (x64 only)
# Based on the solution from GitHub issue vrcx-team/VRCX#1117

set -e

echo "Building VRCX for macOS (x64)..."

# Set DOTNET_ROOT for x64 builds on Apple Silicon
export DOTNET_ROOT=/usr/local/share/dotnet/x64

# Change to project root directory
cd "$(dirname "$0")/.."

# Check if x64 .NET is available
if [[ ! -f "/usr/local/share/dotnet/x64/dotnet" ]]; then
    echo "Error: x64 .NET SDK not found at /usr/local/share/dotnet/x64/"
    echo "Please install .NET 9.0 SDK x64 version for macOS"
    exit 1
fi

# Patch package version
echo "Patching package version..."
node src-electron/patch-package-version.js

# Build the .NET part
echo "Building .NET Electron project..."
/usr/local/share/dotnet/x64/dotnet build Dotnet/VRCX-Electron.csproj -c Release -a x64 -v detailed

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