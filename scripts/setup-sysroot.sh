#!/bin/bash

set -euo pipefail

: "${SDK:?SDK environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"
: "${ARCH:?ARCH environment variable is not set}"
: "${ARCH_ALT:?ARCH_ALT environment variable is not set}"

SYSROOT=${SDK}/sysroots/${ARCH}-gnu-${DEBIAN_RELEASE}
mkdir -p "${SYSROOT}"

cat << EOF > "multistrap.conf"
[General]
arch=${ARCH_ALT}
directory=${SYSROOT}
noauth=true
unpack=true
aptsources=debian
bootstrap=base

[Debian]
source=http://deb.debian.org/debian
suite=${DEBIAN_RELEASE}
components=main
omitdebsrc=true
packages=libc6:${ARCH_ALT} linux-libc-dev:${ARCH_ALT} libstdc++6:${ARCH_ALT} libstdc++-12-dev:${ARCH_ALT} libgcc-s1:${ARCH_ALT} zlib1g:${ARCH_ALT} zlib1g-dev:${ARCH_ALT}
EOF

multistrap -f multistrap.conf
