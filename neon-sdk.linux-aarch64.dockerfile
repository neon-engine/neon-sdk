FROM debian:12

ARG LLVM_MAJOR=18
ARG DEBIAN_RELEASE=bookworm
ARG AARCH_RELEASE=bookworm
ENV SDK=/opt/sdk
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash","-euo","pipefail","-c"]

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    gnupg \
    wget \
    lsb-release \
    file \
    make \
    cmake \
    pkg-config \
    patchelf \
    mmdebstrap \
    binutils \
    gpgv \
    debian-archive-keyring \
 && rm -rf /var/lib/apt/lists/*

RUN echo "deb http://apt.llvm.org/${DEBIAN_RELEASE}/ llvm-toolchain-${DEBIAN_RELEASE}-${LLVM_MAJOR} main" \
      >/etc/apt/sources.list.d/llvm.list \
 && wget -O- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor >/etc/apt/trusted.gpg.d/apt.llvm.org.gpg \
 && apt-get update && apt-get install -y --no-install-recommends \
      clang-${LLVM_MAJOR} clang-tools-${LLVM_MAJOR} lld-${LLVM_MAJOR} \
      llvm-${LLVM_MAJOR} llvm-${LLVM_MAJOR}-tools \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p ${SDK}/llvm-${LLVM_MAJOR}/bin \
 && for b in clang clang++ lld llvm-ar llvm-ranlib llvm-strip llvm-nm; do \
      ln -s /usr/bin/${b}-${LLVM_MAJOR} ${SDK}/llvm-${LLVM_MAJOR}/bin/${b}; \
    done

ENV SYSROOT_A64=${SDK}/sysroots/aarch64-gnu-${AARCH_RELEASE}
RUN mkdir -p "${SYSROOT_A64}" \
 && mmdebstrap --mode=chrootless --variant=minbase \
    --architectures=arm64 \
    --keyring=/usr/share/keyrings/debian-archive-keyring.gpg \
    --setup-hook='mkdir -p "$1/dev"; :> "$1/dev/null"; chmod 666 "$1/dev/null"' \
    --include=g++,binutils,libc6-dev,linux-libc-dev,pkg-config \
    ${AARCH_RELEASE} "${SYSROOT_A64}" http://deb.debian.org/debian \
 && rm -rf "${SYSROOT_A64}"/var/lib/apt/lists/*

RUN mkdir -p ${SDK}/bin ${SDK}/toolchains
RUN cat > ${SDK}/bin/aarch64-gnu-clang <<EOF
#!/usr/bin/env bash
exec ${SDK}/llvm-${LLVM_MAJOR}/bin/clang --target=aarch64-linux-gnu \
  --sysroot=${SDK}/sysroots/aarch64-gnu-bookworm -fuse-ld=lld "\$@"
EOF
RUN cat > ${SDK}/bin/aarch64-gnu-clang++ <<EOF
#!/usr/bin/env bash
exec ${SDK}/llvm-${LLVM_MAJOR}/bin/clang++ --target=aarch64-linux-gnu \
  --sysroot=${SDK}/sysroots/aarch64-gnu-bookworm -stdlib=libstdc++ -fuse-ld=lld "\$@"
EOF
RUN chmod +x ${SDK}/bin/*

RUN cat > ${SDK}/toolchains/aarch64-gnu-clang.cmake <<EOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_SYSROOT "${SDK}/sysroots/aarch64-gnu-bookworm")
set(CMAKE_C_COMPILER   "${SDK}/bin/aarch64-gnu-clang")
set(CMAKE_CXX_COMPILER "${SDK}/bin/aarch64-gnu-clang++")
set(CMAKE_C_COMPILER_TARGET   "aarch64-linux-gnu")
set(CMAKE_CXX_COMPILER_TARGET "aarch64-linux-gnu")
add_link_options(-fuse-ld=lld)
EOF

RUN printf '%s\n' \
  "export CC=${SDK}/bin/aarch64-gnu-clang" \
  "export CXX=${SDK}/bin/aarch64-gnu-clang++" \
  "export AR=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-ar" \
  "export RANLIB=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-ranlib" \
  "export STRIP=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-strip" \
  "export PKG_CONFIG_SYSROOT_DIR=${SDK}/sysroots/aarch64-gnu-bookworm" \
  "export PKG_CONFIG_LIBDIR=${SDK}/sysroots/aarch64-gnu-bookworm/usr/lib/aarch64-linux-gnu/pkgconfig:${SDK}/sysroots/aarch64-gnu-bookworm/usr/lib/pkgconfig:${SDK}/sysroots/aarch64-gnu-bookworm/usr/share/pkgconfig" \
> ${SDK}/env-aarch64-linux.sh
