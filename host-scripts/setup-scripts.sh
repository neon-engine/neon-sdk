#!/bin/bash

set -euo pipefail

: "${SDK:?SDK environment variable is not set}"
: "${SDK_PATH:?SDK_PATH environment variable is not set}"
: "${LLVM_MAJOR:?LLVM_MAJOR environment variable is not set}"
: "${ARCH:?ARCH environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"

# Create bin directory if it doesn't exist
mkdir -p ${SDK}/bin

# Define architectures to process
architectures=("x86_64" "aarch64")

for target_arch in "${architectures[@]}"; do
  target_sysroot=${SDK_PATH}/target/linux-${target_arch}/sysroot/${target_arch}-gnu-${DEBIAN_RELEASE}
  
  # Create clang wrapper
  cat > ${SDK}/bin/${target_arch}-gnu-clang <<EOF
#!/usr/bin/env bash
exec ${SDK}/llvm-${LLVM_MAJOR}/bin/clang \\
  --target=${target_arch}-linux-gnu \\
  --sysroot=${target_sysroot} \\
  -fuse-ld=lld \\
  "\$@"
EOF

echo "wrote ${SDK}/bin/${target_arch}-gnu-clang"

  # Create clang++ wrapper
  cat > ${SDK}/bin/${target_arch}-gnu-clang++ <<EOF
#!/usr/bin/env bash
exec ${SDK}/llvm-${LLVM_MAJOR}/bin/clang++ \\
  --target=${target_arch}-linux-gnu \\
  --sysroot=${target_sysroot} \\
  -stdlib=libstdc++ \\
  -fuse-ld=lld \\
  "\$@"
EOF

echo "wrote ${SDK}/bin/${target_arch}-gnu-clang++"

done

# Make all wrappers executable
chmod +x ${SDK}/bin/*

# Generate toolchain and environment files for each architecture
for target_arch in "${architectures[@]}"; do
  target_sysroot=${SDK_PATH}/target/linux-${target_arch}/sysroot/${target_arch}-gnu-${DEBIAN_RELEASE}
  
  # Create toolchain cmake file
  cat > ${SDK}/${target_arch}-gnu-toolchain.cmake <<EOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ${target_arch})
set(CMAKE_SYSROOT "${target_sysroot}")
set(CMAKE_C_COMPILER   "${SDK}/bin/${target_arch}-gnu-clang")
set(CMAKE_CXX_COMPILER "${SDK}/bin/${target_arch}-gnu-clang++")
set(CMAKE_C_COMPILER_TARGET   "${target_arch}-linux-gnu")
set(CMAKE_CXX_COMPILER_TARGET "${target_arch}-linux-gnu")
add_link_options(-fuse-ld=lld)

# Build type settings
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type: Debug or Release" FORCE)
endif()

# Debug-specific compiler flags
set(CMAKE_C_FLAGS_DEBUG "-g -O0 -DDEBUG" CACHE STRING "C flags for Debug" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -DDEBUG" CACHE STRING "CXX flags for Debug" FORCE)

# Release-specific compiler flags
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG" CACHE STRING "C flags for Release" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG" CACHE STRING "CXX flags for Release" FORCE)

# Enable LTO for Release builds if supported
if(CMAKE_BUILD_TYPE STREQUAL "Release")
  include(CheckIPOSupported)
  check_ipo_supported(RESULT IPO_SUPPORTED)
  if(IPO_SUPPORTED)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
  endif()
endif()
EOF

  # Create environment.sh with separate DEBUG/RELEASE settings
  cat > ${SDK}/${target_arch}-environment.sh <<EOF
export CC=${SDK}/bin/${target_arch}-gnu-clang
export CXX=${SDK}/bin/${target_arch}-gnu-clang++
export AR=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-ar
export RANLIB=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-ranlib
export STRIP=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-strip
export PKG_CONFIG_SYSROOT_DIR=${target_sysroot}
export PKG_CONFIG_LIBDIR=${target_sysroot}/usr/lib/${target_arch}-linux-gnu/pkgconfig:${target_sysroot}/usr/lib/pkgconfig:${target_sysroot}/usr/share/pkgconfig

# Common flags for all build types
export COMMON_FLAGS="-pipe"

# Debug and Release specific flags
export DEBUG_CFLAGS="\${COMMON_FLAGS} -g -O0 -DDEBUG"
export DEBUG_CXXFLAGS="\${COMMON_FLAGS} -g -O0 -DDEBUG"
export RELEASE_CFLAGS="\${COMMON_FLAGS} -O3 -DNDEBUG"
export RELEASE_CXXFLAGS="\${COMMON_FLAGS} -O3 -DNDEBUG"

# Uncomment the build type you want to use:
# For Debug builds:
# export CFLAGS="\${DEBUG_CFLAGS}"
# export CXXFLAGS="\${DEBUG_CXXFLAGS}"

# For Release builds (default):
export CFLAGS="\${RELEASE_CFLAGS}"
export CXXFLAGS="\${RELEASE_CXXFLAGS}"
EOF

  # Create separate files for debug and release environments
  cat > ${SDK}/${target_arch}-environment-debug.sh <<EOF
source ${SDK}/${target_arch}-environment.sh
export CFLAGS="\${DEBUG_CFLAGS}"
export CXXFLAGS="\${DEBUG_CXXFLAGS}"
EOF

  cat > ${SDK}/${target_arch}-environment-release.sh <<EOF
source ${SDK}/${target_arch}-environment.sh
export CFLAGS="\${RELEASE_CFLAGS}"
export CXXFLAGS="\${RELEASE_CXXFLAGS}"
EOF
done

# Make all environment scripts executable
chmod +x ${SDK}/*-environment*.sh
