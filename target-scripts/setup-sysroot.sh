#!/bin/bash

set -euo pipefail

: "${SDK:?SDK environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"
: "${ARCH:?ARCH environment variable is not set}"
: "${ARCH_ALT:?ARCH_ALT environment variable is not set}"

SYSROOT=${SDK}/sysroot/${ARCH}-gnu-${DEBIAN_RELEASE}
mkdir -p "${SYSROOT}"

cat << EOF > "multistrap.conf"
[General]
arch=${ARCH_ALT}
directory=${SYSROOT}
cleanup=true
noauth=false
unpack=true
aptsources=Debian
bootstrap=Debian

[Debian]
packages=libc6 \
  linux-libc-dev \
  libstdc++6 \
  libstdc++-12-dev \
  libgcc-s1 \
  zlib1g \
  zlib1g-dev \
  libvulkan-dev \
  vulkan-validationlayers \
  linux-headers-generic
source=http://deb.debian.org/debian
keyring=debian-archive-keyring
suite=${DEBIAN_RELEASE}
EOF

multistrap -f multistrap.conf
