#!/bin/bash

set -euo pipefail

: "${SDK:?SDK environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"
: "${LLVM_MAJOR:?LLVM_MAJOR environment variable is not set}"

destination=${SDK}/bin/llvm-${LLVM_MAJOR}


git clone https://github.com/llvm/llvm-project.git --depth 1 -b release/${LLVM_MAJOR}.x

mkdir -p build/llvm && cd build/llvm
cmake -G Ninja ../../llvm-project/llvm \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;lldb;openmp" \
  -DLLVM_ENABLE_RUNTIMES="compiler-rt;libcxx;libcxxabi" \
  -DLLVM_TARGETS_TO_BUILD="X86;AArch64" \
  -DLLVM_TOOLCHAIN_TOOLS="llvm-ar;llvm-ranlib;llvm-objdump;llvm-rc;llvm-cvtres;llvm-nm;llvm-strings;llvm-readobj;llvm-dlltool;llvm-pdbutil;llvm-objcopy;llvm-strip;llvm-cov;llvm-profdata;llvm-addr2line;llvm-symbolizer;llvm-windres;llvm-ml;llvm-readelf;llvm-size;llvm-cxxfilt;llvm-lib" \
  -DLLVM_ENABLE_LLD=ON
ninja -j"$(nproc)"

sudo cmake --install . --prefix ${destination}

rm -rf llvm-project
