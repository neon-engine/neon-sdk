FROM debian:12

ARG ARCH=x86_64
ENV ARCH=${ARCH}

ARG LLVM_MAJOR=20
ENV LLVM_MAJOR=${LLVM_MAJOR}

ARG VULKAN_SDK_VERSION=1.3.296
ENV VULKAN_SDK_VERSION=${VULKAN_SDK_VERSION}

ARG DEBIAN_RELEASE=bookworm
ENV DEBIAN_RELEASE=${DEBIAN_RELEASE}

ARG SDK_ROOT=/opt/neon
ENV SDK_ROOT=${SDK_ROOT}
ARG SDK_PATH=${SDK_ROOT}/sdk
ENV SDK=${SDK_PATH}/host/linux-${ARCH}
ENV SYSROOT=${SDK}/sysroot/${ARCH}-gnu-${DEBIAN_RELEASE}

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash","-euo","pipefail","-c"]

COPY host-scripts/ /usr/local/bin/scripts/

RUN chmod +x /usr/local/bin/scripts/*.sh \
  && /usr/local/bin/scripts/setup-base.sh \
  && /usr/local/bin/scripts/setup-scripts.sh \
  && /usr/local/bin/scripts/setup-sysroot.sh \
  && /usr/local/bin/scripts/cleanup.sh

RUN /usr/local/bin/scripts/setup-llvm.sh
