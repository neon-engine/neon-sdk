ARG ARCH=amd64
ARG BASE_IMAGE=ubuntu:22.04
FROM --platform=${ARCH} ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update \
    && apt install -y \
        build-essential \
        wget \
        lsb-release \
        software-properties-common \
        gnupg \
        tzdata \
        libssl-dev \
        mingw-w64 \
        sudo \
        libglm-dev \
        libxcb-dri3-0 \
        libxcb-present0 \
        libpciaccess0 \
        libpng-dev \
        libxcb-keysyms1-dev \
        libxcb-dri3-dev \
        libx11-dev \
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
        pkg-config \
        wayland-protocols \
        python3-jsonschema \
	    clang-format \
        qtbase5-dev \
        qt6-base-dev \
        libxcb-glx0-dev \
        python3 \
        python3-dev \
        swig \
        libedit-dev \
        libncurses5-dev \
        libxml2-dev \
        zlib1g-dev \
        libffi-dev \
        liblzma-dev \
    && mkdir -p /src \
    && mkdir -p /build \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*
