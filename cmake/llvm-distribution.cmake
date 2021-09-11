
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

if(CMAKE_INSTALL_PREFIX)
    message(STATUS "CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")
endif()

set(PACKAGE_VENDOR "awakecoding" CACHE STRING "")

set(LLVM_TARGETS_TO_BUILD
    "X86"
    "ARM"
    "AArch64"
    "Mips"
    "PowerPC"
    "RISCV"
    "NVPTX"
    "Hexagon"
    "WebAssembly"
    CACHE STRING "")

set(LLVM_ENABLE_PROJECTS
    "clang"
    "clang-tools-extra"
    "llvm"
    "lld"
    CACHE STRING "")

set(LLVM_ENABLE_RUNTIMES "" CACHE STRING "")

set(LLVM_ENABLE_BACKTRACES OFF CACHE BOOL "")
set(LLVM_ENABLE_DIA_SDK OFF CACHE BOOL "")
set(LLVM_ENABLE_TERMINFO OFF CACHE BOOL "")
set(LLVM_ENABLE_LIBXML2 ON CACHE BOOL "")
set(LLVM_ENABLE_ZLIB OFF CACHE BOOL "")
set(LLVM_ENABLE_UNWIND_TABLES OFF CACHE BOOL "")
set(LLVM_ENABLE_Z3_SOLVER OFF CACHE BOOL "")
set(LLVM_ENABLE_RTTI ON CACHE BOOL "")
set(LLVM_ENABLE_EH ON CACHE BOOL "")
set(LLVM_INCLUDE_DOCS OFF CACHE BOOL "")
set(LLVM_INCLUDE_TESTS OFF CACHE BOOL "")
set(LLVM_INCLUDE_EXAMPLES OFF CACHE BOOL "")
set(LLVM_INCLUDE_GO_TESTS OFF CACHE BOOL "")

set(LLVM_BUILD_LLVM_C_DYLIB OFF CACHE BOOL "")
set(LLVM_BUILD_32_BITS OFF CACHE BOOL "")

set(LLVM_ENABLE_ASSERTIONS ON CACHE BOOL "")
set(CMAKE_BUILD_TYPE Release CACHE STRING "")

set(LLVM_INSTALL_TOOLCHAIN_ONLY OFF CACHE BOOL "")

set(LLVM_CCTOOLS_COMPONENTS
    llvm-lipo
    llvm-libtool-darwin
    llvm-install-name-tool
    llvm-bitcode-strip
    CACHE STRING "")

set(LLVM_BINUTILS_COMPONENTS
    llvm-ar
    llvm-cxxfilt
    llvm-dwp
    llvm-nm
    llvm-objcopy
    llvm-objdump
    llvm-rc
    llvm-readobj
    llvm-size
    llvm-strings
    llvm-symbolizer
    CACHE STRING "")

set(LLVM_TOOLCHAIN_TOOLS
    dsymutil
    llvm-as
    llvm-cat
    llvm-cov
    llvm-config
    llvm-diff
    llvm-dlltool
    llvm-dwarfdump
    llvm-ifs
    llvm-gsymutil
    llvm-lib
    llvm-link
    llvm-mt
    llvm-pdbutil
    llvm-profdata
    llvm-ranlib
    llvm-readelf
    llvm-strip
    llvm-xray
    ${LLVM_CCTOOLS_COMPONENTS}
    ${LLVM_BINUTILS_COMPONENTS}
    CACHE STRING "")

set(LLVM_DEVELOPMENT_COMPONENTS
    cmake-exports
    llvm-headers
    llvm-libraries
    clang-headers
    clang-libraries
    clang-cmake-exports
    clang-resource-headers
    libclang-headers
    lld-headers # requires patch
    lld-libraries # requires patch
    lld-cmake-exports
    CACHE STRING "")

set(LLVM_DISTRIBUTION_COMPONENTS
    clang
    lld
    LTO
    clang-format
    clang-tidy
    ${LLVM_DEVELOPMENT_COMPONENTS}
    ${LLVM_TOOLCHAIN_TOOLS}
    CACHE STRING "")
