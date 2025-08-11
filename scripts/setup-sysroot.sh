#!/bin/bash

: "${SDK:?SDK environment variable is not set}"
: "${DEBIAN_RELEASE:?DEBIAN_RELEASE environment variable is not set}"

SYSROOT=${SDK}/sysroots/x86_64-gnu-${DEBIAN_RELEASE}
RUN mkdir -p "${SYSROOT}"

mmdebstrap --mode=chrootless --variant=minbase \
  --architectures=amd64 \
  --keyring=/usr/share/keyrings/debian-archive-keyring.gpg \
  --setup-hook='mkdir -p "$1/dev"; :> "$1/dev/null"; chmod 666 "$1/dev/null"' \
  --include=binutils,libc6-dev,linux-libc-dev,libstdc++-12-dev,libgcc-s1,pkg-config \
  "${DEBIAN_RELEASE}" "${SYSROOT}" http://deb.debian.org/debian
