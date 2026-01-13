# Migration Plan: LLVM 16.0.6 → 20.1.0

## Overview
Drop LLVM 16.x support and add LLVM 20.1.0 support, maintaining 18.1.8 as the older stable version.

## 1. Workflow Updates

### llvm-prebuilt.yml
- [ ] Line 12: Change `version: [ 16.0.6, 18.1.8 ]` → `version: [ 18.1.8, 20.1.0 ]`
- [ ] Lines 15-16: Remove 16.0.6 branch mapping
- [ ] Add: `- version: 20.1.0` / `branch: release/20.x`
- [ ] Lines 104-110: Update patch conditional logic
  - Remove: `if ('${{matrix.version}}' -eq '16.0.6')` block
  - Add: `elseif ('${{matrix.version}}' -eq '20.1.0')` block for 20.x patches

### halide-prebuilt.yml
- [ ] Line 18: Change `version: [ 16.0.0, 18.0.0 ]` → `version: [ 18.0.0, 20.0.0 ]`
- [ ] Line 67: Change `$LlvmVersion = "16.0.6"` → `$LlvmVersion = "18.1.8"` or handle dynamically
- [ ] Line 166: Update patch conditional logic
  - Remove: `if ('${{matrix.version}}' -eq '16.0.0')` block
  - Add: `elseif ('${{matrix.version}}' -eq '20.0.0')` block for 20.x patches

## 2. Create LLVM 20 Patches

Need to test if 18.x patches apply cleanly to 20.x, or create new versions:

### LLVM Patches (copy from 18.x as baseline)
- [ ] `llvm-20-add-lld-install-targets.patch`
  - Adds missing `install-lld-headers` and `install-lld-libraries` targets
  - Test on LLVM 20.1.0 release branch

- [ ] `llvm-20-add-llvm-name-prefix-to-llc-lli-opt-tools.patch`
  - Renames `llc`/`lli`/`opt` to avoid conflicts with system tools
  - Verify tool names haven't changed in 20.x

- [ ] `llvm-20-force-disable-clang-ast-introspection.patch`
  - Disables feature causing cross-compilation issues
  - Check if issue still exists in 20.x

### Halide Patches
- [ ] `halide-20-add-halide-host-tools-dir-cmake-option.patch`
- [ ] `halide-20-disable-autoschedulers.patch`
- [ ] `halide-20-disable-clang-verbose-build-warnings.patch`

**Note:** Halide version 20.0.0 may not exist yet. Verify Halide release schedule matches LLVM.

## 3. Delete LLVM 16 Patches

- [ ] `patches/llvm-16-add-lld-install-targets.patch`
- [ ] `patches/llvm-16-add-llvm-name-prefix-to-llc-lli-opt-tools.patch`
- [ ] `patches/llvm-16-force-disable-clang-ast-introspection.patch`
- [ ] `patches/halide-16-add-halide-host-tools-dir-cmake-option.patch`
- [ ] `patches/halide-16-disable-autoschedulers.patch`
- [ ] `patches/halide-16-disable-clang-verbose-build-warnings.patch`

## 4. Documentation Updates

- [ ] `.github/copilot-instructions.md` line 103: Update example from `clang+llvm-16.0.6-...` to `clang+llvm-20.1.0-...`

## 5. Testing Strategy

1. **Verify LLVM 20.1.0 branch exists**: Check https://github.com/llvm/llvm-project/tree/release/20.x
2. **Test patch application**: Clone LLVM 20.1.0 and apply 18.x patches first
3. **Build verification**: Test native x86_64 Ubuntu build first (fastest validation)
4. **Cross-compilation test**: Verify aarch64 builds work with new patches
5. **Halide compatibility**: Confirm Halide 20.0.0 release exists or adjust version

## 6. Potential Issues

- **LLVM 20.x branch availability**: May need to use `llvmorg-20.1.0` tag instead of release branch
- **Halide 20.0.0**: Halide release cadence may not align with LLVM - may need to use 18.0.0 with LLVM 20.1.0
- **API changes**: LLVM 20.x may have CMake or API changes requiring patch adjustments
- **Distribution component names**: Verify `LLVM_DISTRIBUTION_COMPONENTS` names unchanged

## Implementation Order

1. Create LLVM 20 patches (test on local LLVM 20.1.0 checkout)
2. Update llvm-prebuilt.yml workflow
3. Verify LLVM builds work in CI
4. Create/verify Halide 20 patches (if Halide 20.0.0 exists)
5. Update halide-prebuilt.yml workflow
6. Delete 16.x patches
7. Update documentation
8. Commit and test full CI pipeline
