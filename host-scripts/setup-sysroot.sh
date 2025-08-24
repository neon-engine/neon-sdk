#!/bin/bash

set -euo pipefail

: "${SDK_ROOT:?SDK_ROOT environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"

arch=$(uname -m)
declare alt_arch
if [[ "${arch}" == "x86_64" ]]; then
    alt_arch="amd64"
elif [[ "${arch}" == "aarch64" ]]; then
    alt_arch="arm64"
else
    echo "Error: Unsupported architecture '${arch}'" >&2
    exit 1
fi

SYSROOT=${SDK_ROOT}/host/${arch}-gnu-${DEBIAN_RELEASE}
mkdir -p "${SYSROOT}"

cat << EOF > "multistrap.conf"
[General]
arch=${alt_arch}
directory=${SYSROOT}
cleanup=true
noauth=false
unpack=true
aptsources=Debian
bootstrap=Debian

[Debian]
packages=vulkan-tools \
  spirv-tools
source=http://deb.debian.org/debian
keyring=debian-archive-keyring
suite=${DEBIAN_RELEASE}
EOF

multistrap -f multistrap.conf
