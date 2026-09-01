#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-container-hul-common-lib-amaneq-soft-first-trial}"

if ! docker ps --format '{{.Names}}' | grep -Fxq "${CONTAINER_NAME}"; then
  echo "Container is not running: ${CONTAINER_NAME}" >&2
  echo "Start it first with:" >&2
  echo "  bash run-docker-container.sh" >&2
  exit 1
fi

exec docker exec -it "${CONTAINER_NAME}" bash
