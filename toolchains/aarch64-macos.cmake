set(CMAKE_OSX_ARCHITECTURES "arm64")

set(CMAKE_CROSSCOMPILING TRUE)

set(LLVM_TARGET_ARCH AArch64)

include(llvm-distribution.cmake)
