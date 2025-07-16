# VRCX GitHub Workflows

## Overview

This repository contains GitHub Actions workflows for building VRCX across multiple platforms.

## Workflow: `github_actions.yml`

### Supported Platforms

- **Windows** (CEF version) - Builds native Windows executable with installer
- **Linux** (Electron version) - Builds AppImage for Linux distribution
- **macOS** (Electron version) - Builds .app bundle for macOS distribution

### Triggers

The workflow can be triggered by:
- Manual dispatch (`workflow_dispatch`)
- Push to `master` or `main` branches
- Pull requests targeting `master` or `main` branches

### Jobs

1. **set_version** - Generates version numbers and build timestamps
2. **build_dotnet_windows** - Builds Windows CEF version and DB merger
3. **build_dotnet_linux** - Builds Linux Electron .NET backend
4. **build_macos** - Builds macOS Electron app bundle
5. **build_node** - Builds web assets and Linux AppImage
6. **create_setup** - Creates distributable packages for all platforms

### macOS Build Details

The macOS build job (`build_macos`) performs the following steps:

1. **Setup Environment**:
   - Uses `macos-latest` runner
   - Installs .NET 9.0 SDK (x64 architecture)
   - Installs Node.js 18 with npm caching

2. **Build Process**:
   - Validates macOS build configuration
   - Builds .NET backend for macOS
   - Compiles web assets
   - Creates Electron app bundle
   - Signs app with ad-hoc signature

3. **Verification**:
   - Validates that VRCX.app bundle was created
   - Ensures proper file structure

4. **Artifacts**:
   - Uploads VRCX.app bundle as `VRCX-macOS` artifact
   - Creates zip package as `VRCX-macOS-Zip` artifact

### Code Signing

The macOS build uses ad-hoc code signing by default. For distribution with a developer certificate:

1. Add your certificate to the GitHub repository secrets
2. Set the `CODESIGN_IDENTITY` environment variable in the workflow
3. The build script will automatically use the certificate for signing

### Output Artifacts

- `VRCX-Setup` - Windows installer executable
- `VRCX-Zip` - Windows portable zip
- `Electron-AppImage` - Linux AppImage
- `VRCX-macOS` - macOS app bundle
- `VRCX-macOS-Zip` - macOS zip package

### Prerequisites

The workflow automatically installs all required dependencies:
- .NET 9.0 SDK
- Node.js 18+
- Platform-specific build tools

No manual setup is required when running in GitHub Actions.