#!/bin/bash

set -euo pipefail

: "${SDK:?SDK environment variable is not set}"
: "${LLVM_MAJOR:?LLVM_MAJOR environment variable is not set}"
: "${ARCH:?ARCH environment variable is not set}"

mkdir -p ${SDK}/bin ${SDK}/toolchains

cat > ${SDK}/bin/${ARCH}-gnu-clang <<EOF
#!/usr/bin/env bash
exec ${SDK}/llvm-${LLVM_MAJOR}/bin/clang \
  --target=${ARCH}-linux-gnu \
  --sysroot=${SDK}/sysroots/${ARCH}-gnu-bookworm \
  -fuse-ld=lld \
  "\$@"
EOF

cat > ${SDK}/bin/${ARCH}-gnu-clang++ <<EOF
#!/usr/bin/env bash
exec ${SDK}/llvm-${LLVM_MAJOR}/bin/clang++ \
  --target=${ARCH}-linux-gnu \
  --sysroot=${SDK}/sysroots/${ARCH}-gnu-bookworm \
  -stdlib=libstdc++ \
  -fuse-ld=lld \
  "\$@"
EOF

chmod +x ${SDK}/bin/*

cat > ${SDK}/toolchains/${ARCH}-gnu-clang.cmake <<EOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ${ARCH})
set(CMAKE_SYSROOT "${SDK}/sysroots/${ARCH}-gnu-bookworm")
set(CMAKE_C_COMPILER   "${SDK}/bin/${ARCH}-gnu-clang")
set(CMAKE_CXX_COMPILER "${SDK}/bin/${ARCH}-gnu-clang++")
set(CMAKE_C_COMPILER_TARGET   "${ARCH}-linux-gnu")
set(CMAKE_CXX_COMPILER_TARGET "${ARCH}-linux-gnu")
add_link_options(-fuse-ld=lld)
EOF

printf '%s\n' \
  "export CC=${SDK}/bin/${ARCH}-gnu-clang" \
  "export CXX=${SDK}/bin/${ARCH}-gnu-clang++" \
  "export AR=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-ar" \
  "export RANLIB=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-ranlib" \
  "export STRIP=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-strip" \
  "export PKG_CONFIG_SYSROOT_DIR=${SDK}/sysroots/${ARCH}-gnu-bookworm" \
  "export PKG_CONFIG_LIBDIR=${SDK}/sysroots/${ARCH}-gnu-bookworm/usr/lib/${ARCH}-linux-gnu/pkgconfig:${SDK}/sysroots/${ARCH}-gnu-bookworm/usr/lib/pkgconfig:${SDK}/sysroots/${ARCH}-gnu-bookworm/usr/share/pkgconfig" \
> ${SDK}/env-${ARCH}-linux.sh
