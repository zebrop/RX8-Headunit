#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PI_USER="${PI_USER:-brad}"
PI_HOST="${PI_HOST:-172.20.10.9}"
PI_PROJECT_DIR="${PI_PROJECT_DIR:-/home/${PI_USER}/Projects/RX8_HeadUnit}"
PI_BUILD_DIR="${PI_BUILD_DIR:-${PI_PROJECT_DIR}/build-rpi}"
PI_INSTALL_DIR="${PI_INSTALL_DIR:-/opt/Rx8_HeadUnit}"

rsync -az --delete \
  --exclude='.git/' \
  --exclude='build*/' \
  --exclude='.qtcreator/' \
  --exclude='.vscode/' \
  "${ROOT_DIR}/" "${PI_USER}@${PI_HOST}:${PI_PROJECT_DIR}/"

ssh "${PI_USER}@${PI_HOST}" "
  set -euo pipefail
  cd '${PI_PROJECT_DIR}'
  cmake -S . -B '${PI_BUILD_DIR}' -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX='${PI_INSTALL_DIR}' \
    -DBUILD_QDS_COMPONENTS=OFF \
    -DLINK_INSIGHT=OFF
  cmake --build '${PI_BUILD_DIR}' -j\$(nproc)
  sudo cmake --install '${PI_BUILD_DIR}'
"

printf '\nInstalled on Pi: %s@%s:%s\n' "${PI_USER}" "${PI_HOST}" "${PI_INSTALL_DIR}"
printf 'Run on Pi with: ssh %s@%s %s/launch.sh\n' "${PI_USER}" "${PI_HOST}" "${PI_INSTALL_DIR}"
