#!/bin/bash

set -euo pipefail

function show_help() {
  echo "Usage: $0 [-t TARGET] [-h]"
  echo "Build Neon SDK container image"
  echo ""
  echo "Options:"
  echo "  --target TARGET    Specify build target (default: linux-x86_64)"
  echo "  --help             Display this help message and exit"
}

TEMP=$(getopt -o '' --long 'target:,host:,help' -n "$0" -- "$@")
if [ $? -ne 0 ]; then
  echo "Error: Invalid option" >&2
  show_help
  exit 1
fi

eval set -- "$TEMP"

target="linux-x86_64"
declare host

while true; do
  case "$1" in
    --target)
      target="$2"
      shift 2
      ;;
    --host)
      host="$2"
      shift 2
      ;;
    --help)
      show_help
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
done

HOST_TAG="neon-sdk.${target}-$(uname -m)"
HOST_DOCKERFILE="neon-sdk.linux_host.dockerfile"

TAG="neon-sdk.${target}"
DOCKERFILE="${TAG}.dockerfile"

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Error: Dockerfile '${DOCKERFILE}' not found." >&2
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

echo "Building Neon SDK container image for the host: ${host}"
${CONTAINER_ENGINE} ${CONTAINER_COMMAND} -t ${HOST_TAG} -f ${HOST_DOCKERFILE}

echo "Building Neon SDK container image for target: ${target}"
${CONTAINER_ENGINE} ${CONTAINER_COMMAND} -t ${TAG} -f ${DOCKERFILE}

podman create --name ${HOST_TAG}-container ${HOST_TAG}:latest
podman cp ${HOST_TAG}-container:/opt/neon /opt/neon
podman rm ${HOST_TAG}-container

podman create --name ${TAG}-container ${TAG}:latest
podman cp ${TAG}-container:/opt/neon /opt/neon
podman rm ${TAG}-container
