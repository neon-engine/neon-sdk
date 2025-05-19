ARG ARCH=amd64
ARG BASE_IMAGE=ubuntu:22.04
FROM --platform=${ARCH} ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

ARG NINJA_RELEASE_URL_ARG=https://github.com/Kitware/ninja/releases/download
ENV NINJA_RELEASE_URL=${NINJA_RELEASE_URL_ARG}

ARG NINJA_VERSION_ARG=1.11.1.g95dee.kitware.jobserver-1
ENV NINJA_VERSION=${NINJA_VERSION_ARG}

ARG GCC_VERSION_ARG=13.3.0
ENV GCC_VERSION=${GCC_VERSION_ARG}

ARG LLVM_VERSION_ARG=llvmorg-20.1.4
ENV LLVM_VERSION=${LLVM_VERSION_ARG}

ARG CMAKE_VERSION_ARG=3.28.3
ENV CMAKE_VERSION=${CMAKE_VERSION_ARG}

ARG VULKAN_SDK_VERSION_ARG=1.4.313.0
ENV VULKAN_SDK_VERSION=${VULKAN_SDK_VERSION_ARG}

ENV NEON_SDK_PATH=/opt/neon-sdk
ENV PATH=${NEON_SDK_PATH}/gcc-${GCC_VERSION}/bin:$PATH
ENV LD_LIBRARY_PATH=${NEON_SDK_PATH}/gcc-${GCC_VERSION}/lib64:$LD_LIBRARY_PATH

COPY scripts/* /usr/bin
COPY build-neon-sdk /usr/bin

RUN mkdir -p ${NEON_SDK_PATH} \
    && apt update \
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
    && apt clean \
    && rm -rf /var/lib/apt/lists/*
RUN install-ninja
RUN build-cmake
RUN build-gcc
RUN build-llvm
RUN build-vulkan-sdk
