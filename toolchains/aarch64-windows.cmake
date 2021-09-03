set(CMAKE_SYSTEM_PROCESSOR "ARM64")

set(CMAKE_CROSSCOMPILING TRUE)

set(LLVM_TARGET_ARCH AArch64)

include("${CMAKE_CURRENT_LIST_DIR}/llvm-distribution.cmake")
