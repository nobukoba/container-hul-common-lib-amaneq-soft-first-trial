#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-container-hul-common-lib-amaneq-soft-first-trial:latest}"
WORK_DIR="${WORK_DIR:-$PWD/work}"
CONTAINER_NAME="${CONTAINER_NAME:-container-hul-common-lib-amaneq-soft-first-trial}"

mkdir -p "${WORK_DIR}"

docker run --rm -it \
  --name "${CONTAINER_NAME}" \
  --platform linux/amd64/v2 \
  --network host \
  -v "${WORK_DIR}:/work" \
  "${IMAGE}"
