#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${HERE}/.." && pwd)"
APP_NAME="SlothOS-BT-Gamepad"
OUT_DIR="${1:-${REPO_ROOT}/dist}"
OUT_FILE="${OUT_DIR}/${APP_NAME}.muxapp"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

PKG_DIR="${TMP_DIR}/${APP_NAME}"
mkdir -p "${PKG_DIR}/glyph"

FILES=(
  main.py
  bt_l2cap_v2.py
  BluezProfile.py
  BluezAgent.py
  hid_descriptor.py
  evdev_to_hid.py
  evdev_reader.py
  sdp_record_gamepad.xml
  sdp_record_pnp.xml
  set_did.py
  requirements.txt
)

for rel in "${FILES[@]}"; do
  cp "${REPO_ROOT}/${rel}" "${PKG_DIR}/${rel}"
done

cp "${HERE}/mux_launch.sh" "${PKG_DIR}/mux_launch.sh"
chmod 755 "${PKG_DIR}/mux_launch.sh"

if [[ -f "${REPO_ROOT}/app/icon.png" ]]; then
  cp "${REPO_ROOT}/app/icon.png" "${PKG_DIR}/glyph/btgamepad.png"
fi

mkdir -p "${OUT_DIR}"

python3 - "${TMP_DIR}" "${APP_NAME}" "${OUT_FILE}" <<'PY'
import pathlib
import sys
import zipfile

tmp_dir = pathlib.Path(sys.argv[1])
app_name = sys.argv[2]
out_file = pathlib.Path(sys.argv[3])
root = tmp_dir / app_name

with zipfile.ZipFile(out_file, "w", zipfile.ZIP_DEFLATED) as zf:
    for path in root.rglob("*"):
        zf.write(path, path.relative_to(tmp_dir))
PY

echo "Created ${OUT_FILE}"
