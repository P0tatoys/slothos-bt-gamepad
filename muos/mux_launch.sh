#!/bin/sh
# TITLE: SlothOS BT Gamepad
# DESC: Bluetooth HID gamepad mode for RG35XX H
# ICON: btgamepad

set -eu

# muOS helper funcs (best-effort).
. /mnt/mod/ctrl/configs/functions >/dev/null 2>&1 || true

export HOME=/root
export PYTHONUNBUFFERED=1

APP_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LOG_FILE="${APP_DIR}/log.txt"
INPUT_DEV="${BT_GAMEPAD_INPUT_DEVICE:-/dev/input/event1}"

# Best-effort adapter bring-up for cold boots.
hciconfig hci0 up >/dev/null 2>&1 || true
hciconfig hci0 auth >/dev/null 2>&1 || true

cd "${APP_DIR}"
exec /usr/bin/python3 "${APP_DIR}/main.py" \
  --verbose \
  --device "${INPUT_DEV}" >>"${LOG_FILE}" 2>&1
