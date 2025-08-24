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
packages=libglm-dev \
    cmake \
    libxcb-dri3-0 \
    libxcb-present0 \
    libpciaccess0 \
    libpng-dev \
    libxcb-keysyms1-dev \
    libxcb-dri3-dev \
    libx11-dev \
    g++ \
    gcc \
    libwayland-dev \
    libxrandr-dev \
    libxcb-randr0-dev \
    libxcb-ewmh-dev \
    git \
    python-is-python3 \
    bison \
    libx11-xcb-dev \
    liblz4-dev \
    libzstd-dev \
    ocaml-core \
    ninja-build \
    pkg-config \
    libxml2-dev \
    wayland-protocols \
    python3-jsonschema \
    clang-format \
    qtbase5-dev \
    qt6-base-dev \
    libxcb-glx0-dev
source=http://deb.debian.org/debian
keyring=debian-archive-keyring
suite=${DEBIAN_RELEASE}
EOF

multistrap -f multistrap.conf


