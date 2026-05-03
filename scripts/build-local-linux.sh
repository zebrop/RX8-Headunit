#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build-local"

cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}" -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DBUILD_QDS_COMPONENTS=OFF \
  -DLINK_INSIGHT=OFF

cmake --build "${BUILD_DIR}" -j"$(nproc)"

printf '\nBuilt: %s/Rx8_HeadUnitApp\n' "${BUILD_DIR}"
printf 'Run with: RX8_TEENSY_PORT=/dev/ttyUSB0 %s/Rx8_HeadUnitApp\n' "${BUILD_DIR}"
