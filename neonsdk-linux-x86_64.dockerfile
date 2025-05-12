ARG ARCH=amd64
ARG BASE_IMAGE=ubuntu:22.04
FROM --platform=${ARCH} ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ARG NINJA_RELEASE_URL=https://github.com/Kitware/ninja/releases/download
ARG NINJA_VERSION=1.11.1.g95dee.kitware.jobserver-1
ARG GCC_VERSION=13.3.0
ARG LLVM_VERSION=17
ARG CMAKE_VERSION=3.28.3
ARG VULKAN_SDK_VERSION=1.4.313.0

ENV PATH=/opt/gcc-${GCC_VERSION}/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/gcc-${GCC_VERSION}/lib64:$LD_LIBRARY_PATH

RUN apt update && apt install -y \
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
        libxcb-glx0-dev \
    && wget -O ninja.tar.gz ${NINJA_RELEASE_URL}/v${NINJA_VERSION}/ninja-${NINJA_VERSION}_$(uname -m)-linux-gnu.tar.gz \
    && tar --strip-components=1 -xzf ninja.tar.gz \
    && mv ninja /opt/ninja \
    && rm -f ninja.tar.gz \
    # Build CMake from source
    && wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz \
    && tar -zxvf cmake-${CMAKE_VERSION}.tar.gz \
    && cd cmake-${CMAKE_VERSION} \
    && ./bootstrap --prefix=/opt/cmake-${CMAKE_VERSION} --parallel=$(nproc) \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf cmake-${CMAKE_VERSION} cmake-${CMAKE_VERSION}.tar.gz \
    # Updated GCC and libstdc++
    && wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz \
    && tar -xvf gcc-${GCC_VERSION}.tar.xz \
    && cd gcc-${GCC_VERSION} \
    && ./contrib/download_prerequisites \
    && cd .. \
    && mkdir gcc-build \
    && cd gcc-build \
    && ../gcc-${GCC_VERSION}/configure \
        --prefix=/opt/gcc-${GCC_VERSION} \
        --enable-languages=c,c++ \
        --disable-multilib \
        --disable-bootstrap \
        --enable-checking=release \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf gcc-* \
    && update-alternatives --install /usr/bin/gcc gcc /opt/gcc-${GCC_VERSION}/bin/gcc 100 \
    && update-alternatives --install /usr/bin/g++ g++ /opt/gcc-${GCC_VERSION}/bin/g++ 100 \
    # LLVM/clang
    && wget https://apt.llvm.org/llvm.sh \
    && chmod +x llvm.sh \
    && ./llvm.sh ${LLVM_VERSION} \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VERSION} 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VERSION} 100 \
    && apt clean
    # Vulkan SDK
RUN mkdir -p /opt/vulkan \
    && cd /opt/vulkan \
    && wget https://sdk.lunarg.com/sdk/download/${VULKAN_SDK_VERSION}/linux/vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.tar.xz \
    && tar -xvf vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.tar.xz \
        ${VULKAN_SDK_VERSION}/setup-env.sh \
        ${VULKAN_SDK_VERSION}/vulkansdk \
        ${VULKAN_SDK_VERSION}/LICENSE.txt \
        ${VULKAN_SDK_VERSION}/README.txt \
        ${VULKAN_SDK_VERSION}/config/vk_layer_settings.txt \
    && rm -f vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.tar.xz \
    && ls -la ${VULKAN_SDK_VERSION} \
    && . ${VULKAN_SDK_VERSION}/setup-env.sh \
    && ./${VULKAN_SDK_VERSION}/vulkansdk --skip-deps --maxjobs
