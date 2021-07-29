# LLVM Nightlies ![build status badge](https://github.com/alexreinking/llvm-nightlies/workflows/LLVM%20Nightlies/badge.svg)

This is a stub repo to make nightly LLVM packages via GitHub Actions.

For each of LLVM 10, 11, 12, and `main` branch, it builds binaries for the following architectures:

Arch                  | Windows            | macOS                    | Linux
----------------------|--------------------|--------------------------|--------------------
x86 (32-bit)          | :heavy_check_mark: | :heavy_multiplication_x: | :heavy_check_mark: 
x86 (64-bit)          | :heavy_check_mark: | :heavy_check_mark:       | :heavy_check_mark: 
ARM (32-bit, hf)      | :x:                | :heavy_multiplication_x: | :heavy_check_mark: 
ARM (64-bit, aarch64) | :x:                | :x:                      | :heavy_check_mark: 
