#!/bin/bash

set -euo pipefail

: "${SDK_ROOT:?SDK_ROOT environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"

SYSROOT=${SDK_ROOT}/host/$(uname -m)-gnu-${DEBIAN_RELEASE}
mkdir -p "${SYSROOT}"

cat << EOF > "multistrap.conf"
[General]
arch=$(uname -m)
directory=${SYSROOT}
cleanup=true
noauth=false
unpack=true
aptsources=Debian
bootstrap=Debian

[Debian]
packages=libc6 \
  vulkan-tools \
  spirv-tools
source=http://deb.debian.org/debian
keyring=debian-archive-keyring
suite=${DEBIAN_RELEASE}
EOF

multistrap -f multistrap.conf
