#!/usr/bin/env bash
# apk_integrity.sh — on-device sha256 of every installed APK, optional host-side cert fingerprint
# Usage: ./apk_integrity.sh [out.csv] [--pull]
set -u
out="${1:-apk_integrity_$(date +%Y%m%d_%H%M%S).csv}"
pull=0; [ "${2:-}" = "--pull" ] && pull=1
mkdir -p apks
if command -v apksigner >/dev/null 2>&1; then have_apksigner=1; else have_apksigner=0; fi
if [ $pull -eq 1 ] && [ $have_apksigner -eq 0 ]; then
  echo "WARN: --pull set but apksigner not found; cert_sha256 column will be empty" >&2
fi
echo "package,apk_path,sha256_on_device,cert_sha256" > "$out"
adb shell pm list packages -f | tr -d '\r' | sed 's/^package://' | while read -r line; do
  apk=${line%%=*}; pkg=${line#*=}; pkg=${pkg%% *}
  h=$(adb shell sha256sum "$apk" 2>/dev/null | tr -d '\r' | awk '{print $1}')
  cert=""
  if [ $pull -eq 1 ]; then
    dest="apks/${pkg}.apk"
    adb pull "$apk" "$dest" >/dev/null 2>&1
    if [ $have_apksigner -eq 1 ] && [ -s "$dest" ]; then
      cert=$(apksigner verify --print-certs "$dest" 2>/dev/null \
        | grep -m1 "certificate SHA-256 digest" | sed 's/.*digest: *//;s/://g')
    fi
  fi
  echo "$pkg,$apk,$h,$cert" >> "$out"
done
echo "wrote $out"
