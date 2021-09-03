
if(DEFINED ENV{CMAKE_INSTALL_PREFIX})
    set(CMAKE_INSTALL_PREFIX $ENV{CMAKE_INSTALL_PREFIX} CACHE FILEPATH "")
endif()

if(DEFINED ENV{CLANG_TABLEGEN})
    set(CLANG_TABLEGEN $ENV{CLANG_TABLEGEN} CACHE FILEPATH "")
    message(STATUS "CLANG_TABLEGEN: ${CLANG_TABLEGEN}")
endif()

if(DEFINED ENV{LLVM_TABLEGEN})
    set(LLVM_TABLEGEN $ENV{LLVM_TABLEGEN} CACHE FILEPATH "")
    message(STATUS "LLVM_TABLEGEN: ${LLVM_TABLEGEN}")
endif()

if(DEFINED ENV{LLVM_CONFIG_PATH})
    set(LLVM_CONFIG_PATH $ENV{LLVM_CONFIG_PATH} CACHE FILEPATH "")
    message(STATUS "LLVM_CONFIG_PATH: ${LLVM_CONFIG_PATH}")
endif()

set(PACKAGE_VENDOR "awakecoding" CACHE STRING "")

set(LLVM_TARGETS_TO_BUILD "X86;ARM;AArch64;Mips;PowerPC;RISCV;WebAssembly" CACHE STRING "")

set(LLVM_ENABLE_PROJECTS "clang;clang-tools-extra;lld" CACHE STRING "")
set(LLVM_ENABLE_RUNTIMES "compiler-rt;libunwind;libcxx;libcxxabi" CACHE STRING "")

if(WIN32)
    set(LLVM_USE_CRT_RELEASE "MT" CACHE STRING "")
endif()

set(LLVM_INSTALL_TOOLCHAIN_ONLY ON CACHE BOOL "")

set(LLVM_TOOLCHAIN_TOOLS
    dsymutil
    llvm-ar
    llvm-bitcode-strip
    llvm-cat
    llvm-cov
    llvm-config
    llvm-cxxfilt
    llvm-diff
    llvm-dlltool
    llvm-dwarfdump
    llvm-dwp
    llvm-ifs
    llvm-install-name-tool
    llvm-gsymutil
    llvm-lib
    llvm-libtool-darwin
    llvm-lipo
    llvm-mt
    llvm-nm
    llvm-objcopy
    llvm-objdump
    llvm-pdbutil
    llvm-profdata
    llvm-rc
    llvm-ranlib
    llvm-readelf
    llvm-readobj
    llvm-size
    llvm-strings
    llvm-strip
    llvm-symbolizer
    llvm-xray
    CACHE STRING "")

set(LLVM_DISTRIBUTION_COMPONENTS
    clang
    lld
    LTO
    clang-format
    clang-tidy
    builtins
    runtimes
    ${LLVM_TOOLCHAIN_TOOLS}
    CACHE STRING "")
