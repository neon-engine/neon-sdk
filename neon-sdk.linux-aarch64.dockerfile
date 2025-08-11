FROM debian:12

ARG LLVM_MAJOR=18
ENV LLVM_MAJOR=18
ARG DEBIAN_RELEASE=bookworm
ARG AARCH_RELEASE=bookworm
ENV SDK=/opt/sdk
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash","-euo","pipefail","-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      mmdebstrap \
      gpgv \
      debian-archive-keyring \
      gpg \
      wget \
    && rm -rf /var/lib/apt/lists/*

RUN 

ENV SYSROOT_A64=${SDK}/sysroots/aarch64-gnu-${AARCH_RELEASE}
RUN mkdir -p "${SYSROOT_A64}" \
 && mmdebstrap --mode=chrootless --variant=minbase \
    --architectures=arm64 \
    --keyring=/usr/share/keyrings/debian-archive-keyring.gpg \
    --setup-hook='mkdir -p "$1/dev"; :> "$1/dev/null"; chmod 666 "$1/dev/null"' \
    --include=g++,binutils,libc6-dev,linux-libc-dev,pkg-config \
    ${DEBIAN_RELEASE} "${SYSROOT_A64}" http://deb.debian.org/debian \
 && chroot "${SYSROOT_A64}" apt-get update \
 && chroot "${SYSROOT_A64}" apt-get install -y --no-install-recommends \
      g++ binutils libc6-dev linux-libc-dev pkg-config \
 && chroot "${SYSROOT_A64}" apt-get clean \
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
