#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest}"
PLATFORM="${PLATFORM:-linux/amd64}"
WORKSPACE_DIR="${WORKSPACE_DIR:-$PWD}"
CONTAINER_NAME="${CONTAINER_NAME:-container-hul-common-lib-amaneq-soft-first-trial}"

docker run --rm -it \
  --name "${CONTAINER_NAME}" \
  --platform "${PLATFORM}" \
  --network host \
  -v "${WORKSPACE_DIR}:/workspace" \
  "${IMAGE}"
