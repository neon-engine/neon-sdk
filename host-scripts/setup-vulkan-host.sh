#!/bin/bash

set -euo pipefail

: "${VULKAN_SDK_VERSION:?VULKAN_SDK_VERSION environment variable is not set}"

echo "Fetching Vulkan SDK ${VULKAN_SDK_VERSION}"
wget https://sdk.lunarg.com/sdk/download/${VULKAN_SDK_VERSION}.0/linux/vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.0.tar.xz

tar -xvf vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.0.tar.xz \
    ${VULKAN_SDK_VERSION}.0/setup-env.sh \
    ${VULKAN_SDK_VERSION}.0/vulkansdk \
    ${VULKAN_SDK_VERSION}.0/LICENSE.txt \
    ${VULKAN_SDK_VERSION}.0/README.txt \
    ${VULKAN_SDK_VERSION}.0/config/vk_layer_settings.txt

rm -f vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.0.tar.xz

cd ${VULKAN_SDK_VERSION}.0
source setup-env.sh

./vulkansdk.modified --skip-deps --maxjobs \
    shaderc \
    glslang \
    spirv-tools \
    spirv-cross \
    gfxrecon \
    lunarg-tools \
    vulkan-profiles \
    volk \
    vma
