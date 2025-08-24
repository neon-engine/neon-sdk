#!/bin/bash

set -euo pipefail

apt-get update

apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    file \
    make \
    cmake \
    pkg-config \
    patchelf \
    mmdebstrap \
    binutils \
    gpgv \
    debian-archive-keyring \
    lsb-release \
    wget \
    software-properties-common \
    gnupg \
    multistrap
