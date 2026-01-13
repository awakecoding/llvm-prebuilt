# LLVM Prebuilt - AI Coding Agent Instructions

## Project Overview

This repository builds custom cross-platform LLVM/Clang distributions and Halide packages for **x86_64** and **aarch64** architectures across **Windows**, **macOS**, **Ubuntu 22.04**, and **Ubuntu 24.04**. The build system uses CMake toolchain files and applies version-specific patches to produce minimal, installable distributions.

## Core Architecture

### Build Pipeline Structure
- **Stage 1 (Host Tools)**: Native build of `llvm-tblgen`, `clang-tblgen`, `llvm-config`, and clang-tools-extra generators
- **Stage 2 (Cross-Compilation)**: Target build using host tools and architecture-specific toolchain files
- **Distribution**: Uses `install-distribution` target with custom component lists from [cmake/llvm-distribution.cmake](../cmake/llvm-distribution.cmake)

### Critical Build Workflow
```bash
# 1. Build host tools (always native architecture)
cmake -G Ninja -S llvm-project/llvm -B llvm-host \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
  -DCMAKE_BUILD_TYPE=Release
cmake --build llvm-host --target llvm-tblgen clang-tblgen llvm-config

# 2. Configure target build with toolchain
cmake -G Ninja -S llvm-project/llvm -B llvm-build \
  -DCMAKE_TOOLCHAIN_FILE=cmake/<arch>-<os>.cmake \
  -C cmake/llvm-distribution.cmake \
  -DLLVM_NATIVE_TOOL_DIR=llvm-host/bin

# 3. Build and install distribution
cmake --build llvm-build
cmake --build llvm-build --target install-distribution
```

## Toolchain File System

Toolchain files in [cmake/](../cmake/) follow a strict **include hierarchy**:
- Platform-specific configs (e.g., `x86_64-ubuntu-22.04.cmake`) include base configs (e.g., `x86_64-linux.cmake`)
- Base configs set `CMAKE_SYSTEM_NAME`, `CMAKE_SYSTEM_PROCESSOR`, cross-compilation flags, and default target triples
- **Always test both Ubuntu versions separately** - they require different library packages (see workflow deps)

### Key Variables
- `LLVM_NATIVE_TOOL_DIR`: Points to host-built tablegen tools (required for cross-compilation)
- `LLVM_DISTRIBUTION_COMPONENTS`: Defines what gets installed (includes dev headers, libraries, lld components, tools)
- `PACKAGE_VENDOR`: Set to `"awakecoding"` for branding

## Patch Management

Patches in [patches/](../patches/) are **version-specific** (18.x vs 20.x) and must be applied before configuration:
- **lld-install-targets**: Adds missing `install-lld-headers` and `install-lld-libraries` targets
- **llvm-name-prefix**: Renames `llc`/`lli`/`opt` to avoid conflicts with system tools
- **force-disable-clang-ast-introspection**: Disables feature causing cross-compilation issues

**Pattern**: When updating LLVM versions, verify all three patch categories apply cleanly. Test on Linux first (fastest builds).

## Dependency Handling

### Linux (Ubuntu)
Cross-compilation requires **arm64 library installation**. Use the [Get-UbuntuPackage.ps1](../scripts/Get-UbuntuPackage.ps1) script to automatically download packages:
```powershell
# Automatically resolves latest package version from packages.ubuntu.com
./scripts/Get-UbuntuPackage.ps1 -PackageName libxml2-dev -Release 22.04 -Architecture arm64
./scripts/Get-UbuntuPackage.ps1 -PackageName zlib1g-dev -Release 24.04 -Architecture arm64
```

The script:
1. Maps release numbers to codenames (22.04 → jammy, 24.04 → noble)
2. Scrapes packages.ubuntu.com to find the latest .deb download URL
3. Downloads and extracts the package (handles .zst, .xz, .gz compression)
4. Returns the extraction directory path

**Why this matters**: Hardcoding package filenames (e.g., `libxml2-dev_2.9.13+dfsg-1build1_arm64.deb`) breaks when Ubuntu updates packages. This script eliminates that brittleness.

### Windows
Uses vcpkg for static dependencies: `zlib:<arch>-windows-static-release` and `libxml2:<arch>-windows-static-release`

### macOS
System libraries work directly; specify `CMAKE_OSX_ARCHITECTURES` for universal builds

## Testing Changes

**Local testing pattern** (fastest verification):
1. Test on Ubuntu x86_64 first (native build, no cross-compilation complexity)
2. Verify patches apply: `git -C llvm-project apply ../patches/llvm-<version>-*.patch`
3. Check distribution components: `cmake --build llvm-build --target help | grep install-`
4. Validate package contents: `tar -tvf clang+llvm-*.tar.xz | grep -E '(bin|lib|include)'`

## Halide Integration

The [halide-prebuilt.yml](../.github/workflows/halide-prebuilt.yml) workflow:
- **Depends on llvm-prebuilt artifacts** (downloads from previous workflow run via `llvm_run_id` input)
- Uses downloaded LLVM as `LLVM_DIR` for Halide CMake configuration
- Applies parallel Halide patches (disable autoschedulers, add host tools dir option)

## Common Pitfalls

1. **Cross-compilation failures**: Always ensure `LLVM_NATIVE_TOOL_DIR` points to host-built tools
2. **Missing install targets**: Verify lld patches applied if `install-lld-*` targets fail
3. **Library linking errors on Linux aarch64**: Double-check aarch64 library extraction and sudo copy steps
4. **Windows static linking**: Must use vcpkg's `-static-release` variants, not shared libs
5. **macOS deployment target**: Set `MACOSX_DEPLOYMENT_TARGET=10.13` for compatibility

## File Naming Conventions

Artifacts follow pattern: `clang+llvm-<version>-<arch>-<os>.tar.xz` (e.g., `clang+llvm-20.1.8-aarch64-ubuntu-22.04.tar.xz`)
