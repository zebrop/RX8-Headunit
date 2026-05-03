#!/usr/bin/env bash
set -euo pipefail

export RX8_TEENSY_PORT="${RX8_TEENSY_PORT:-/dev/ttyAMA0}"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-eglfs}"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${DIR}/Rx8_HeadUnitApp"
