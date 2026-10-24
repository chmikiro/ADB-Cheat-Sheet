#!/usr/bin/env bash
out="${1:-packages_$(date +%Y%m%d_%H%M%S).csv}"
echo "package,uid,installer,apk_path,type,enabled" > "$out"
dis=$(adb shell pm list packages -d | tr -d '\r' | cut -d: -f2)
sys=$(adb shell pm list packages -s | tr -d '\r' | cut -d: -f2)
adb shell pm list packages -f -i -U | tr -d '\r' | sed 's/^package://' | while read -r l; do
  apk=${l%%=*}; r=${l#*=}; pkg=${r%% *}
  inst=$(echo "$r" | sed -n 's/.*installer=\([^ ]*\).*/\1/p'); uid=$(echo "$r" | sed -n 's/.*uid:\([0-9]*\).*/\1/p')
  t=user; grep -qx "$pkg" <<<"$sys" && t=system
  e=enabled; grep -qx "$pkg" <<<"$dis" && e=disabled
  echo "$pkg,$uid,$inst,$apk,$t,$e"
done >> "$out"
echo "wrote $out"
