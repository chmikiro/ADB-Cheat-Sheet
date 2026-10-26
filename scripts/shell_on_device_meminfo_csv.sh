#!/system/bin/sh
out=/sdcard/mem.csv
[ -f $out ] || echo "ts,MemAvailable_kB,SwapFree_kB" > $out
a=$(awk '/MemAvailable/{print $2}' /proc/meminfo); s=$(awk '/SwapFree/{print $2}' /proc/meminfo)
echo "$(date +%FT%T),$a,$s" >> $out
