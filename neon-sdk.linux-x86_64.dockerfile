FROM debian:12

ENV ARCH=x86_64
ENV ARCH_ALT=amd64

ARG DEBIAN_RELEASE=bookworm
ENV DEBIAN_RELEASE=${DEBIAN_RELEASE}

ARG SDK_ROOT=/opt/neon
ENV SDK_ROOT=${SDK_ROOT}
ARG SDK_PATH=${SDK_ROOT}/sdk
ENV SDK=${SDK_PATH}/${ARCH}

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash","-euo","pipefail","-c"]

COPY target-scripts/ /usr/local/bin/scripts/

RUN chmod +x /usr/local/bin/scripts/*.sh \
  && /usr/local/bin/scripts/setup-base.sh \
  && /usr/local/bin/scripts/setup-sysroot.sh \
  && /usr/local/bin/scripts/setup-scripts.sh \
  && /usr/local/bin/scripts/cleanup.sh
