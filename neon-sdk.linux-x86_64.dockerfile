FROM debian:12

ARG ARCH=x86_64
ENV ARCH=${ARCH}

ARG ARCH_ALT=amd64
ENV ARCH_ALT=${ARCH_ALT}

ARG LLVM_MAJOR=18
ENV LLVM_MAJOR=${LLVM_MAJOR}

ARG DEBIAN_RELEASE=bookworm
ENV DEBIAN_RELEASE=${DEBIAN_RELEASE}

ENV SDK=/opt/sdk
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash","-euo","pipefail","-c"]

COPY scripts/ /usr/local/bin/scripts/

RUN chmod +x /usr/local/bin/scripts/*.sh \
  && /usr/local/bin/scripts/setup-base.sh \
  && /usr/local/bin/scripts/get-llvm.sh \
  && /usr/local/bin/scripts/setup-sysroot.sh \
  && /usr/local/bin/scripts/setup-scripts.sh \
  && /usr/local/bin/scripts/cleanup.sh
