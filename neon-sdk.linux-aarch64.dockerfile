FROM debian:12

ARG ARCH=aarch64
ENV ARCH=${ARCH}

ARG ARCH_ALT=arm64
ENV ARCH_ALT=${ARCH_ALT}

ARG LLVM_MAJOR=18
ENV LLVM_MAJOR=${LLVM_MAJOR}

ARG DEBIAN_RELEASE=bookworm
ENV DEBIAN_RELEASE=${DEBIAN_RELEASE}

ARG SDK_PATH=/opt/neon/sdk
ENV SDK=${SDK_PATH}
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash","-euo","pipefail","-c"]

COPY scripts/ /usr/local/bin/scripts/

RUN chmod +x /usr/local/bin/scripts/*.sh \
  && /usr/local/bin/scripts/setup-base.sh \
  && /usr/local/bin/scripts/setup-sysroot.sh \
  && /usr/local/bin/scripts/setup-scripts.sh \
  && /usr/local/bin/scripts/cleanup.sh
