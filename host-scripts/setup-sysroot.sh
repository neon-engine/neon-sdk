#!/bin/bash

set -euo pipefail

: "${SDK:?SDK environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"
: "${ARCH:?ARCH environment variable is not set}"


declare alt_arch
if [[ "${ARCH}" == "x86_64" ]]; then
    alt_arch="amd64"
elif [[ "${ARCH}" == "aarch64" ]]; then
    alt_arch="arm64"
else
    echo "Error: Unsupported architecture '${ARCH}'" >&2
    exit 1
fi


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
