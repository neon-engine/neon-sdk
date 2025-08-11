#!/bin/bash

set -euo pipefail

: "${SDK:?SDK environment variable is not set}"
: "${LLVM_MAJOR:?LLVM_MAJOR environment variable is not set}"

mkdir -p ${SDK}/bin ${SDK}/toolchains

cat > ${SDK}/bin/x86_64-gnu-clang <<EOF
#!/usr/bin/env bash
exec ${SDK}/llvm-${LLVM_MAJOR}/bin/clang --target=x86_64-linux-gnu \
  --sysroot=${SDK}/sysroots/x86_64-gnu-bookworm -fuse-ld=lld "\$@"
EOF

cat > ${SDK}/bin/x86_64-gnu-clang++ <<EOF
#!/usr/bin/env bash
exec ${SDK}/llvm-${LLVM_MAJOR}/bin/clang++ --target=x86_64-linux-gnu \
  --sysroot=${SDK}/sysroots/x86_64-gnu-bookworm -stdlib=libstdc++ -fuse-ld=lld "\$@"
EOF

chmod +x ${SDK}/bin/*

cat > ${SDK}/toolchains/x86_64-gnu-clang.cmake <<EOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_SYSROOT "${SDK}/sysroots/x86_64-gnu-bookworm")
set(CMAKE_C_COMPILER   "${SDK}/bin/x86_64-gnu-clang")
set(CMAKE_CXX_COMPILER "${SDK}/bin/x86_64-gnu-clang++")
set(CMAKE_C_COMPILER_TARGET   "x86_64-linux-gnu")
set(CMAKE_CXX_COMPILER_TARGET "x86_64-linux-gnu")
add_link_options(-fuse-ld=lld)
EOF

printf '%s\n' \
  "export CC=${SDK}/bin/x86_64-gnu-clang" \
  "export CXX=${SDK}/bin/x86_64-gnu-clang++" \
  "export AR=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-ar" \
  "export RANLIB=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-ranlib" \
  "export STRIP=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-strip" \
  "export PKG_CONFIG_SYSROOT_DIR=${SDK}/sysroots/x86_64-gnu-bookworm" \
  "export PKG_CONFIG_LIBDIR=${SDK}/sysroots/x86_64-gnu-bookworm/usr/lib/x86_64-linux-gnu/pkgconfig:${SDK}/sysroots/x86_64-gnu-bookworm/usr/lib/pkgconfig:${SDK}/sysroots/x86_64-gnu-bookworm/usr/share/pkgconfig" \
> ${SDK}/env-x86_64-linux.sh
