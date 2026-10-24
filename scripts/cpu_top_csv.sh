#!/usr/bin/env bash
iv="${1:-5}"; n="${2:-30}"; out="${3:-cpu_top_$(date +%Y%m%d_%H%M%S).csv}"
echo "timestamp,pid,user,cpu_pct,rss_kb,name" > "$out"
for ((i=0;i<n;i++)); do
  ts=$(date -Iseconds)
  adb shell "top -b -n 1 -m 15 -o PID,USER,%CPU,RES,ARGS" 2>/dev/null | tr -d '\r' | awk -v ts="$ts" '
    $1 ~ /^[0-9]+$/ {
      res=$4; if(res ~ /M$/){sub(/M/,"",res); res=res*1024} else if(res ~ /G$/){sub(/G/,"",res); res=res*1048576} else if(res ~ /K$/){sub(/K/,"",res)}
      printf "%s,%s,%s,%s,%d,%s\n", ts,$1,$2,$3,res,$5 }' >> "$out"
  sleep "$iv"
done
echo "wrote $out"
