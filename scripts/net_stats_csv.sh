#!/usr/bin/env bash
out="${1:-net_stats_$(date +%Y%m%d_%H%M%S).csv}"
echo "timestamp,uid,rx_bytes,tx_bytes" > "$out"
ts=$(date -Iseconds)
if adb shell test -r /proc/net/xt_qtaguid/stats 2>/dev/null; then
  adb shell cat /proc/net/xt_qtaguid/stats | tr -d '\r' | awk -v ts="$ts" 'NR>1{rx[$4]+=$6; tx[$4]+=$8} END{for(u in rx) printf "%s,%s,%d,%d\n",ts,u,rx[u],tx[u]}' >> "$out"
else
  adb shell dumpsys netstats --uid | tr -d '\r' > "${out%.csv}.raw.txt"
  echo "xt_qtaguid unavailable (Android 10+); raw dump saved to ${out%.csv}.raw.txt"
fi
echo "wrote $out"
