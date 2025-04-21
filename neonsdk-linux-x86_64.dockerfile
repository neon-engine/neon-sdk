FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ARG NINJA_RELEASE_URL=https://github.com/Kitware/ninja/releases/download
ARG NINJA_VERSION=1.11.1.g95dee.kitware.jobserver-1
ARG GCC_VERSION=13.3.0
ARG LLVM_VERSION=17

ENV PATH=/opt/gcc-${GCC_VERSION}/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/gcc-${GCC_VERSION}/lib64:$LD_LIBRARY_PATH

RUN apt update && apt install -y \
        build-essential \
        git \
        wget \
        lsb-release \
        software-properties-common \
        gnupg \
        tzdata \
        cmake \
    && wget -O ninja.tar.gz ${NINJA_RELEASE_URL}/v${NINJA_VERSION}/ninja-${NINJA_VERSION}_$(uname -m)-linux-gnu.tar.gz \
    && tar --strip-components=1 -xzf ninja.tar.gz \
    && mv ninja /usr/bin/ninja \
    && rm -f ninja.tar.gz \
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
