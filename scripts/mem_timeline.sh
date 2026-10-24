#!/usr/bin/env bash
iv="${1:-5}"; n="${2:-60}"; out="${3:-mem_timeline_$(date +%Y%m%d_%H%M%S).csv}"
echo "timestamp,MemTotal_kB,MemFree_kB,MemAvailable_kB,Cached_kB,SwapTotal_kB,SwapFree_kB,Dirty_kB,Slab_kB" > "$out"
for ((i=0;i<n;i++)); do
  adb shell cat /proc/meminfo | tr -d '\r' | awk -v ts="$(date -Iseconds)" '
    /^MemTotal:/{a=$2} /^MemFree:/{b=$2} /^MemAvailable:/{c=$2} /^Cached:/{d=$2}
    /^SwapTotal:/{e=$2} /^SwapFree:/{f=$2} /^Dirty:/{g=$2} /^Slab:/{h=$2}
    END{printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\n",ts,a,b,c,d,e,f,g,h}' >> "$out"
  sleep "$iv"
done
echo "wrote $out"
