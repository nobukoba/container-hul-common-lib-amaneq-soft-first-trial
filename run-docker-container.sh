#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/nobukoba/container-hul-common-lib-amaneq-soft-first-trial:latest}"
PLATFORM="${PLATFORM:-linux/amd64/v2}"
WORK_DIR="${WORK_DIR:-$PWD/work}"
CONTAINER_NAME="${CONTAINER_NAME:-container-hul-common-lib-amaneq-soft-first-trial}"

mkdir -p "${WORK_DIR}"

docker run --rm -it \
  --name "${CONTAINER_NAME}" \
  --platform "${PLATFORM}" \
  --network host \
  -v "${WORK_DIR}:/work" \
  "${IMAGE}"
