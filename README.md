# LLVM Prebuilt

This repository builds custom prebuilt toolchain packages for LLVM/Clang, Halide, Linux cctools, and platform SDK/toolchain support bundles. It is intended for reproducible GitHub Actions builds across the major desktop operating systems and CPU architectures used by downstream native projects.

You can download published packages from the [GitHub releases page](https://github.com/awakecoding/llvm-prebuilt/releases), or run the workflows in this repository to produce your own artifacts.

## Packages

### LLVM/Clang

The LLVM workflow builds minimal installable Clang/LLVM distributions with Clang, LLD, selected LLVM tools, development headers, CMake exports, zlib, and libxml2 support.

Currently built LLVM versions: `18.1.8`, `20.1.8`.

| Arch    | Windows | macOS | Ubuntu 22.04 | Ubuntu 24.04 |
|---------|---------|-------|--------------|--------------|
| x86_64  | Yes     | Yes   | Yes          | Yes          |
| aarch64 | Yes     | Yes   | Yes          | Yes          |

Artifacts are named:

```text
clang+llvm-<version>-<arch>-<os>.tar.xz
```

### Halide

The Halide workflow builds Halide packages against LLVM artifacts produced by the LLVM workflow. It first installs a host LLVM package, then installs a target LLVM package when cross-compiling for `aarch64`.

Currently built Halide versions: `18.0.0`, `19.0.0`.

| Arch    | Windows | macOS | Ubuntu 22.04 | Ubuntu 24.04 |
|---------|---------|-------|--------------|--------------|
| x86_64  | Yes     | Yes   | Yes          | Yes          |
| aarch64 | Yes     | Yes   | Yes          | Yes          |

Artifacts are named:

```text
halide-<version>-<arch>-<os>.tar.xz
```

### cctools

The cctools workflow builds Linux packages containing the Apple cctools port and supporting libraries.

| Arch    | Windows | macOS | Ubuntu 22.04 | Ubuntu 24.04 |
|---------|---------|-------|--------------|--------------|
| x86_64  | No      | No    | Yes          | Yes          |
| aarch64 | No      | No    | Yes          | Yes          |

Artifacts are named:

```text
cctools-<arch>-<os>.tar.xz
```

### Platform Bundles

Additional workflows package host platform support files:

| Workflow | Artifact |
|----------|----------|
| MSVC bundle | `vctools.tar.xz`, `winsdk.tar.xz` |
| Xcode bundle | `xcode-bundle.tar.xz` |

## Repository Layout

| Path | Purpose |
|------|---------|
| `.github/workflows/llvm-prebuilt.yml` | Builds LLVM/Clang packages. |
| `.github/workflows/halide-prebuilt.yml` | Builds Halide packages from LLVM workflow artifacts. |
| `.github/workflows/cctools-prebuilt.yml` | Builds Linux cctools packages. |
| `.github/workflows/github-release.yml` | Downloads workflow artifacts, creates checksums, and publishes a release. |
| `cmake/*.cmake` | LLVM and Halide toolchain files plus LLVM distribution cache settings. |
| `patches/*.patch` | Version-specific LLVM and Halide patches applied before configuration. |
| `scripts/Get-UbuntuPackage.ps1` | Resolves, downloads, and extracts Ubuntu packages for Linux cross-compilation. |

## Build Overview

LLVM builds use a two-stage flow:

1. Build native host tools from `llvm/llvm-project`, including `llvm-tblgen`, `clang-tblgen`, and `llvm-config`.
2. Configure and build the target distribution with the matching `cmake/<arch>-<os>.cmake` toolchain file and `cmake/llvm-distribution.cmake` initial cache.

The distribution surface is controlled by `cmake/llvm-distribution.cmake`. It enables Clang, clang-tools-extra, LLVM, LLD, the selected target backends, development headers/libraries, CMake exports, and selected toolchain utilities.

Halide builds follow a similar host/target split. Host tools such as `build_halide_h`, `binary2cpp`, and `regexp_replace` are built first, then reused through the `HALIDE_HOST_TOOLS_DIR` CMake option added by the repository patches.

## Running the Workflows

All major package workflows are manually triggered with `workflow_dispatch`.

Recommended order:

1. Run `LLVM prebuilt`.
2. Run `halide prebuilt` with the LLVM workflow run ID, or use `latest`.
3. Run `cctools prebuilt` if Linux cctools artifacts are needed.
4. Run `GitHub Release` with the desired workflow run IDs to collect artifacts and publish a release.

The release workflow supports `dry-run` and `draft-release` inputs. Keep `dry-run` enabled while checking artifact collection and checksums.

## Local Development Notes

The workflows use PowerShell heavily, including on Linux runners, so PowerShell-compatible commands are preferred when updating scripts or documentation.

For Linux `aarch64` cross-compilation, do not hardcode Ubuntu `.deb` filenames. Use `scripts/Get-UbuntuPackage.ps1`, which maps Ubuntu releases to codenames, resolves current package filenames through `packages.ubuntu.com`, downloads the package, and extracts the data archive.

Patch files are version-specific. When adding or updating upstream LLVM or Halide versions, keep workflow conditionals and patch filenames in sync, then verify that patches apply cleanly before testing the build.

Generated upstream source trees and build directories should remain untracked. Common local directories include `llvm-project`, `llvm-host`, `llvm-build`, `halide`, `halide-host`, and `halide-build`.

## Example LLVM Configure Commands

Build native host tools:

```powershell
cmake -G Ninja -S llvm-project/llvm -B llvm-host `
	-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" `
	-DCMAKE_BUILD_TYPE=Release -Wno-dev

cmake --build llvm-host --target llvm-tblgen clang-tblgen llvm-config
```

Configure a target LLVM build:

```powershell
cmake -G Ninja -S llvm-project/llvm -B llvm-build `
	-DCMAKE_INSTALL_PREFIX=llvm-install `
	-DCMAKE_TOOLCHAIN_FILE="$PWD/cmake/x86_64-ubuntu-24.04.cmake" `
	-C "$PWD/cmake/llvm-distribution.cmake" -Wno-dev
```

Build and install the distribution:

```powershell
cmake --build llvm-build
cmake --build llvm-build --target install-distribution
```

Full local builds are large. For broad changes, start with an Ubuntu `x86_64` LLVM build, then validate `aarch64` cross-compilation and the Ubuntu release variants separately.
