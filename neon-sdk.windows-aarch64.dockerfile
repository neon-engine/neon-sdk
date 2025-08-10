FROM debian:12

ARG LLVM_MAJOR=18
ARG DEBIAN_RELEASE=bookworm
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
    mingw-w64 \
    binutils \
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

RUN mkdir -p ${SDK}/bin ${SDK}/toolchains
RUN cat > ${SDK}/bin/aarch64-windows-clang++ <<EOF
#!/usr/bin/env bash
exec ${SDK}/llvm-${LLVM_MAJOR}/bin/clang++ --target=aarch64-w64-windows-gnu \
  -fuse-ld=lld -stdlib=libstdc++ -gcc-toolchain /usr "\$@"
EOF
RUN chmod +x ${SDK}/bin/*

RUN cat > ${SDK}/toolchains/aarch64-windows-mingw-clang.cmake <<EOF
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_C_COMPILER   "${SDK}/bin/aarch64-windows-clang++")
set(CMAKE_CXX_COMPILER "${SDK}/bin/aarch64-windows-clang++")
set(CMAKE_C_COMPILER_TARGET   "aarch64-w64-windows-gnu")
set(CMAKE_CXX_COMPILER_TARGET "aarch64-w64-windows-gnu")
add_link_options(-fuse-ld=lld)
EOF

RUN printf '%s\n' \
  "export CC=${SDK}/bin/aarch64-windows-clang++" \
  "export CXX=${SDK}/bin/aarch64-windows-clang++" \
  "export AR=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-ar" \
  "export RANLIB=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-ranlib" \
  "export STRIP=${SDK}/llvm-${LLVM_MAJOR}/bin/llvm-strip" \
> ${SDK}/env-aarch64-windows.sh
