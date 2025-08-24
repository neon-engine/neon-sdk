#!/bin/bash

set -euo pipefail

: "${SDK:?SDK environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"
: "${LLVM_MAJOR:?LLVM_MAJOR environment variable is not set}"

echo "deb http://apt.llvm.org/${DEBIAN_RELEASE}/ llvm-toolchain-${DEBIAN_RELEASE}-${LLVM_MAJOR} main" > /etc/apt/sources.list.d/llvm.list

wget -O- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor >/etc/apt/trusted.gpg.d/apt.llvm.org.gpg

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh ${LLVM_MAJOR} all

mkdir -p ${SDK}/llvm-${LLVM_MAJOR}/bin
for b in clang clang++ lld llvm-ar llvm-ranlib llvm-strip llvm-nm; do
    ln -s /usr/bin/${b}-${LLVM_MAJOR} ${SDK}/llvm-${LLVM_MAJOR}/bin/${b};
done