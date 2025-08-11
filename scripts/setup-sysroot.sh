#!/bin/bash

: "${SDK:?SDK environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"

SYSROOT=${SDK}/sysroots/x86_64-gnu-${DEBIAN_RELEASE}
RUN mkdir -p "${SYSROOT}"

mmdebstrap --mode=chrootless --variant=minbase \
    --architectures=amd64 \
    --keyring=/usr/share/keyrings/debian-archive-keyring.gpg \
    --setup-hook='mkdir -p "$1/dev"; :> "$1/dev/null"; chmod 666 "$1/dev/null"' \
    --include=g++,binutils,libc6-dev,linux-libc-dev,pkg-config \
    ${DEBIAN_RELEASE} "${SYSROOT}" http://deb.debian.org/debian
chroot "${SYSROOT}" apt-get update
chroot "${SYSROOT}" apt-get install -y --no-install-recommends \
      libstdc++-12-dev \
      binutils \
      libc6-dev \
      linux-libc-dev \
      pkg-config
chroot "${SYSROOT}" apt-get clean
rm -rf "${SYSROOT}"/var/lib/apt/lists/*
