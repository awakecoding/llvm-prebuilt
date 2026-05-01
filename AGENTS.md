# AGENTS.md

## Project Scope

This repository builds prebuilt LLVM/Clang, Halide, cctools, MSVC, and Xcode support bundles for release artifacts. Most meaningful behavior lives in GitHub Actions workflows, CMake toolchain/cache files, and version-specific patches applied to external upstream checkouts.

Treat this as a packaging and cross-compilation repository. Keep changes small, reproducible in CI, and aligned with the existing matrix of:

- Architectures: `x86_64`, `aarch64`
- Platforms: `windows`, `macos`, `ubuntu-22.04`, `ubuntu-24.04`
- LLVM versions currently built by CI: `18.1.8`, `20.1.8`
- Halide versions currently built by CI: `18.0.0`, `19.0.0`

## Repository Layout

- `.github/workflows/llvm-prebuilt.yml` builds and packages LLVM/Clang distributions.
- `.github/workflows/halide-prebuilt.yml` builds Halide packages using LLVM artifacts from a previous LLVM workflow run.
- `.github/workflows/cctools-prebuilt.yml` builds Linux cctools artifacts.
- `.github/workflows/msvc-bundle.yml` and `.github/workflows/xcode-bundle.yml` package platform SDK/toolchain support files.
- `.github/workflows/github-release.yml` downloads workflow artifacts, creates checksums, and publishes a GitHub release.
- `cmake/*.cmake` contains target toolchain files plus `llvm-distribution.cmake`, the LLVM initial cache that defines the installable distribution surface.
- `patches/*.patch` contains version-specific patches applied to upstream LLVM or Halide sources after checkout.
- `scripts/Get-UbuntuPackage.ps1` resolves, downloads, and extracts Ubuntu packages for Linux aarch64 cross-compilation.

## Build Model

LLVM builds are two-stage:

1. Build native host tools from the upstream LLVM checkout with Ninja.
2. Configure the target LLVM build with the matching `cmake/<arch>-<os>.cmake` toolchain file and `-C cmake/llvm-distribution.cmake`.

Important variables exported by CI and consumed by `llvm-distribution.cmake` include:

- `LLVM_NATIVE_TOOL_DIR`
- `LLVM_TABLEGEN`
- `CLANG_TABLEGEN`
- `LLVM_CONFIG_PATH`
- `LLVM_VERSION`
- `CMAKE_INSTALL_PREFIX`

Do not remove the host-tools phase when changing cross-compilation behavior. Cross builds depend on native tablegen/config/helper tools.

## Local Verification Commands

Prefer PowerShell-compatible commands because the workflows use `pwsh` heavily across platforms.

Patch application smoke test:

```powershell
git -C llvm-project apply ../llvm-prebuilt/patches/llvm-20-add-lld-install-targets.patch
git -C llvm-project apply ../llvm-prebuilt/patches/llvm-20-add-llvm-name-prefix-to-llc-lli-opt-tools.patch
```

LLVM host tools:

```powershell
cmake -G Ninja -S llvm-project/llvm -B llvm-host `
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" `
  -DCMAKE_BUILD_TYPE=Release -Wno-dev
cmake --build llvm-host --target llvm-tblgen clang-tblgen llvm-config
```

LLVM target configuration:

```powershell
cmake -G Ninja -S llvm-project/llvm -B llvm-build `
  -DCMAKE_INSTALL_PREFIX=llvm-install `
  -DCMAKE_TOOLCHAIN_FILE="$PWD/llvm-prebuilt/cmake/x86_64-ubuntu-24.04.cmake" `
  -C "$PWD/llvm-prebuilt/cmake/llvm-distribution.cmake" -Wno-dev
```

LLVM package build/install targets:

```powershell
cmake --build llvm-build
cmake --build llvm-build --target install-distribution
```

When validating a broad change, test Ubuntu x86_64 first because it is the simplest build path, then test aarch64 cross-compilation and both Ubuntu releases separately.

## Toolchain File Rules

- Keep platform leaf files small. Ubuntu files should include the matching base Linux file.
- Base Linux files set `CMAKE_SYSTEM_NAME`, `CMAKE_SYSTEM_PROCESSOR`, cross-compilation state, compilers, target architecture, and target triples.
- Windows toolchains set `CMAKE_SYSTEM_NAME` and processor only; CI supplies MSVC target environments with `ilammy/msvc-dev-cmd`.
- macOS toolchains set `CMAKE_SYSTEM_NAME Darwin` and `CMAKE_OSX_ARCHITECTURES`; CI sets `MACOSX_DEPLOYMENT_TARGET`.
- Preserve the `aarch64`/`arm64` distinction: artifact and matrix names use `aarch64`; Apple CMake architecture values use `arm64`; Windows MSVC target architecture values use `arm64`.

## LLVM Distribution Rules

`cmake/llvm-distribution.cmake` is the distribution contract. Be careful when changing:

- `LLVM_ENABLE_PROJECTS`
- `LLVM_TARGETS_TO_BUILD`
- `LLVM_DISTRIBUTION_COMPONENTS`
- `LLVM_DEVELOPMENT_COMPONENTS`
- tool utility/component lists

The lld development components depend on the `llvm-*-add-lld-install-targets.patch` patch. If lld install components fail, verify the matching lld patch still applies and still creates the expected install targets before changing the component list.

The `llc`, `lli`, and `opt` tools are patched to install as `llvm-llc`, `llvm-lli`, and `llvm-opt` to avoid system tool conflicts. Account for that naming in tests, package inspections, and docs.

## Patch Management

- Patches are version-specific. Add new patch files for new upstream major versions instead of silently reusing an older filename.
- Apply patches after checking out upstream `llvm/llvm-project` or `halide/Halide`, before CMake configuration.
- Keep LLVM patch conditionals in `.github/workflows/llvm-prebuilt.yml` in sync with files under `patches/llvm-*`.
- Keep Halide patch conditionals in `.github/workflows/halide-prebuilt.yml` in sync with files under `patches/halide-*`.
- When updating LLVM, verify all patch categories: lld install targets, LLVM tool name prefixes, and any cross-compilation feature disables still needed for that version.
- When updating Halide, verify all patch categories: host tools directory option, autoscheduler disablement, and verbose warning suppression.

## Linux Dependency Handling

Linux aarch64 cross-compilation needs target `arm64` libraries. Do not hardcode Ubuntu `.deb` filenames in workflows. Use `scripts/Get-UbuntuPackage.ps1` so package filenames are resolved from `packages.ubuntu.com`.

Current workflow dependencies include native `libxml2-dev` and `zlib1g-dev`, plus extracted arm64 `libxml2-dev` and `zlib1g-dev` copied into `/usr/lib/aarch64-linux-gnu/`.

The helper maps Ubuntu release numbers to codenames, currently including `22.04` -> `jammy` and `24.04` -> `noble`. If adding Ubuntu releases, update this mapping and test both package resolution and extraction formats (`.zst`, `.xz`, `.gz`).

## Windows and macOS Notes

Windows LLVM builds use vcpkg static-release packages:

- `zlib:<arch>-windows-static-release`
- `libxml2:<arch>-windows-static-release`

Keep Windows package paths aligned with vcpkg's installed package directory names and use `7z` packaging as in CI.

macOS LLVM builds use the system SDK/toolchain and set `MACOSX_DEPLOYMENT_TARGET=10.13`. Halide uses `10.13` for 18.x and `10.15` for 19.x because of `std::filesystem` requirements.

## Artifact Naming

Keep artifact names stable; downstream workflows and release publishing depend on them.

- LLVM: `clang+llvm-<version>-<arch>-<os>.tar.xz`
- Halide: `halide-<version>-<arch>-<os>.tar.xz`
- cctools: `cctools-<arch>-<os>.tar.xz`
- SDK/toolchain bundles: `vctools.tar.xz`, `winsdk.tar.xz`, `xcode-bundle.tar.xz`

## Release Workflow

`.github/workflows/github-release.yml` expects successful artifact-producing workflow runs. It accepts `llvm_run_id`, `halide_run_id`, and `cctools_run_id`, each supporting `latest`, plus `dry-run` and `draft-release` controls.

When changing artifact names, matrix dimensions, or workflow names, update release download logic at the same time.

## Coding and Review Guidance

- Favor CI-compatible PowerShell for scripts and workflow snippets.
- Keep CMake cache/toolchain changes explicit and minimal.
- Avoid broad refactors of workflow steps unless required by the requested behavior.
- Do not check in generated upstream source trees or build directories such as `llvm-project`, `llvm-host`, `llvm-build`, `halide`, `halide-host`, or package extraction folders.
- Preserve unrelated user changes in the working tree.
- Before finishing changes that affect builds, run the narrowest practical validation: patch-apply checks, CMake configure, target listing, or package-content inspection.
- If a full LLVM or Halide build is impractical locally, state what was validated and what still requires CI.