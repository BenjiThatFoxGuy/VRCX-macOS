# VRCX macOS Build Instructions

This document explains how to build the Electron version of VRCX for macOS.

## Prerequisites

1. **macOS 10.15 (Catalina) or later**
2. **Node.js 18 or later**
3. **.NET 9.0 SDK (x64 version)** - Required for building the C# backend
4. **Xcode Command Line Tools** - For code signing

## Installation

### 1. Install .NET 9.0 SDK (x64)

Download and install the x64 version of .NET 9.0 SDK from:
https://dotnet.microsoft.com/download/dotnet/9.0

**Important:** Make sure to install the x64 version, not the ARM64 version, even on Apple Silicon Macs. The x64 version will be installed to `/usr/local/share/dotnet/x64/`.

### 2. Install Node.js

Download and install Node.js from:
https://nodejs.org/

### 3. Install Xcode Command Line Tools

```bash
xcode-select --install
```

## Building VRCX

### Test Setup (Recommended First Step)

Before building, you can test that everything is configured correctly:

```bash
npm run test-macos-setup
```

This will verify that all necessary components are in place and configured properly.

### Quick Build (Recommended)

```bash
npm run build-macos
```

This will automatically:
- Set up the correct environment variables
- Build the .NET backend
- Install npm dependencies
- Build the web assets
- Create the Electron app bundle
- Sign the app with an ad-hoc signature

### Manual Build Steps

If you prefer to build manually or need to customize the build process:

1. **Set environment variables:**
   ```bash
   export DOTNET_ROOT=/usr/local/share/dotnet/x64
   ```

2. **Patch package version:**
   ```bash
   node src-electron/patch-package-version.js
   ```

3. **Build the .NET backend:**
   ```bash
   /usr/local/share/dotnet/x64/dotnet build Dotnet/VRCX-Electron.csproj -c Release -a x64 -v detailed
   ```

4. **Install npm dependencies:**
   ```bash
   npm install --arch=x64
   ```

5. **Build web assets:**
   ```bash
   npm run prod-linux --arch=x64
   ```

6. **Build Electron app:**
   ```bash
   ./node_modules/.bin/electron-builder --mac --x64 -c.mac.minimumSystemVersion=10.15.0 -c.mac.target=dir -c.mac.identity=null -c.mac.category=public.app-category.utilities
   ```

7. **Sign the app (optional):**
   ```bash
   codesign --sign - --deep build/mac/VRCX.app/
   ```

## Running VRCX

After building, you can find the VRCX.app bundle in the `build/mac/` directory. Double-click to run, or use:

```bash
open build/mac/VRCX.app
```

## Development

For development, you can use:

```bash
npm run start-electron
```

This will start VRCX in development mode after building the necessary components.

## Troubleshooting

### "DOTNET_ROOT not found" Error

Make sure you have the x64 version of .NET 9.0 SDK installed and that it's located at `/usr/local/share/dotnet/x64/`.

### SQLite Issues

The macOS build includes pre-built SQLite libraries for x64. If you encounter SQLite-related errors, make sure you're building with the x64 architecture.

### Code Signing

The build script uses ad-hoc signing by default. For distribution, you may need to use proper Apple Developer certificates.

## Architecture Support

Currently, only x64 (Intel) architecture is supported. The app will run on Apple Silicon Macs through Rosetta 2.

## Based on Solution

This build configuration is based on the community solution provided in [vrcx-team/VRCX#1117](https://github.com/vrcx-team/VRCX/issues/1117).