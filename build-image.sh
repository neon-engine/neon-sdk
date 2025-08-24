#!/bin/bash

set -euo pipefail

target=${1:-"linux-x86_64"}

if [[ "${target}" == "linux-host" ]]; then
  target="linux-host-$(uname -m)"
fi

echo "Building Neon SDK container image for target: $target"

TAG="neon-sdk.${target}"
DOCKERFILE="${TAG}.dockerfile"

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Error: Dockerfile '$DOCKERFILE' not found." >&2
  exit 1
fi

declare CONTAINER_ENGINE
declare CONTAINER_COMMAND
if command -v podman >/dev/null 2>&1; then
  CONTAINER_ENGINE="podman"
  CONTAINER_COMMAND="build --format docker"
elif command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    CONTAINER_ENGINE="docker"
    CONTAINER_COMMAND="build"
  else
    echo "Error: docker found but daemon not reachable." >&2
    exit 1
  fi
else
  echo "Error: neither podman nor docker found in PATH." >&2
  exit 1
fi

${CONTAINER_ENGINE} ${CONTAINER_COMMAND} -t ${TAG} -f ${DOCKERFILE}
