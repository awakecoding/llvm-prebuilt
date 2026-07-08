# Slim Clang toolchain for cross-building Apple arm64 binaries from Linux x86_64.
# This cache intentionally omits LLVM libraries, headers, CMake exports,
# clang-tools-extra, llc/lli/opt, runtimes, and any tool not needed for a
# fake Xcode cross-build layout.

if(DEFINED ENV{CMAKE_INSTALL_PREFIX})
    set(CMAKE_INSTALL_PREFIX $ENV{CMAKE_INSTALL_PREFIX} CACHE FILEPATH "")
endif()

if(DEFINED ENV{LLVM_NATIVE_TOOL_DIR})
    set(LLVM_NATIVE_TOOL_DIR $ENV{LLVM_NATIVE_TOOL_DIR} CACHE FILEPATH "")
    message(STATUS "LLVM_NATIVE_TOOL_DIR: ${LLVM_NATIVE_TOOL_DIR}")
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

if(DEFINED ENV{LLVM_VERSION})
    set(LLVM_VERSION $ENV{LLVM_VERSION} CACHE FILEPATH "")
    message(STATUS "LLVM_VERSION: ${LLVM_VERSION}")
endif()

if(CMAKE_INSTALL_PREFIX)
    message(STATUS "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")
endif()

set(PACKAGE_VENDOR "awakecoding" CACHE STRING "")

# Apple arm64 only: no Intel Mac, no iOS simulator x64, no other backends.
set(LLVM_TARGETS_TO_BUILD
    "AArch64"
    CACHE STRING "")

set(LLVM_ENABLE_PROJECTS
    "clang"
    "lld"
    "llvm"
    CACHE STRING "")

set(LLVM_ENABLE_RUNTIMES "" CACHE STRING "")

set(LLVM_ENABLE_BACKTRACES OFF CACHE BOOL "")
set(LLVM_ENABLE_DIA_SDK OFF CACHE BOOL "")
set(LLVM_ENABLE_TERMINFO OFF CACHE BOOL "")
set(LLVM_ENABLE_LIBXML2 ON CACHE BOOL "")
set(LLVM_ENABLE_ZLIB ON CACHE BOOL "")
set(LLVM_ENABLE_ZSTD OFF CACHE BOOL "")
set(LLVM_ENABLE_UNWIND_TABLES OFF CACHE BOOL "")
set(LLVM_ENABLE_Z3_SOLVER OFF CACHE BOOL "")
set(LLVM_ENABLE_RTTI OFF CACHE BOOL "")
set(LLVM_ENABLE_EH OFF CACHE BOOL "")
set(LLVM_INCLUDE_DOCS OFF CACHE BOOL "")
set(LLVM_INCLUDE_TESTS OFF CACHE BOOL "")
set(LLVM_INCLUDE_EXAMPLES OFF CACHE BOOL "")
set(LLVM_INCLUDE_GO_TESTS OFF CACHE BOOL "")

set(LLVM_BUILD_LLVM_C_DYLIB OFF CACHE BOOL "")
set(LLVM_BUILD_32_BITS OFF CACHE BOOL "")

set(LLVM_ENABLE_ASSERTIONS OFF CACHE BOOL "")
set(CMAKE_BUILD_TYPE Release CACHE STRING "")

set(LLVM_INSTALL_TOOLCHAIN_ONLY OFF CACHE BOOL "")

# Apple-specific cctools equivalents shipped by LLVM.
set(LLVM_CCTOOLS_COMPONENTS
    llvm-lipo
    llvm-libtool-darwin
    llvm-install-name-tool
    llvm-bitcode-strip
    CACHE STRING "")

# Minimal Mach-O binutils required by the cross-build and fake Xcode layout.
set(LLVM_BINUTILS_COMPONENTS
    llvm-ar
    llvm-cxxfilt
    llvm-nm
    llvm-objcopy
    llvm-objdump
    llvm-readobj
    llvm-size
    llvm-strings
    llvm-symbolizer
    CACHE STRING "")

# Core compiler toolchain utilities. Keep only the ones actually used.
set(LLVM_TOOLCHAIN_TOOLS
    dsymutil
    llvm-ranlib
    llvm-strip
    ${LLVM_CCTOOLS_COMPONENTS}
    ${LLVM_BINUTILS_COMPONENTS}
    CACHE STRING "")

set(LLVM_DISTRIBUTION_COMPONENTS
    clang
    clang-resource-headers
    lld
    ${LLVM_TOOLCHAIN_TOOLS}
    CACHE STRING "")
