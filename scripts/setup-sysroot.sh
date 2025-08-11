#!/bin/bash

set -euo pipefail

: "${SDK:?SDK environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"
: "${ARCH:?ARCH environment variable is not set}"
: "${ARCH_ALT:?ARCH_ALT environment variable is not set}"

SYSROOT=${SDK}/sysroots/${ARCH}-gnu-${DEBIAN_RELEASE}
mkdir -p "${SYSROOT}"

HOST_ARCH=$(uname -m)
declare CHROOT_ARCH

if [[ "${HOST_ARCH}" == "${ARCH_ALT}" ]]; then
  CHROOT_ARCH="${HOST_ARCH}"
else
  CHROOT_ARCH="${HOST_ARCH} ${ARCH_ALT}"
fi

mmdebstrap --mode=chrootless --variant=minbase \
  --architectures="${CHROOT_ARCH}" \
  --keyring=/usr/share/keyrings/debian-archive-keyring.gpg \
  --setup-hook='mkdir -p "$1/dev"; :> "$1/dev/null"; chmod 666 "$1/dev/null"' \
  --include="binutils:${ARCH_ALT},libc6-dev:${ARCH_ALT},linux-libc-dev:${ARCH_ALT},libstdc++-12-dev:${ARCH_ALT},libgcc-s1:${ARCH_ALT},pkg-config:${ARCH_ALT}" \
  "${DEBIAN_RELEASE}" "${SYSROOT}" http://deb.debian.org/debian
