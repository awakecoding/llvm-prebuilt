set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_CROSSCOMPILING TRUE)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

set(LLVM_TARGET_ARCH AArch64)
set(LLVM_DEFAULT_TARGET_TRIPLE aarch64-linux-gnu)

include(llvm-distribution.cmake)
