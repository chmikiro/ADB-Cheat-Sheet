#!/usr/bin/env bash
out="${1:-net_conns_$(date +%Y%m%d_%H%M%S).csv}"
ts=$(date -Iseconds)
echo "timestamp,proto,local,remote,state,uid,package" > "$out"
declare -A pk
while read -r line; do
  pkg=${line#package:}; pkg=${pkg%% *}; uid=${line##*uid:}
  pk[$uid]="$pkg"
done < <(adb shell pm list packages -U | tr -d '\r')
hex2ip() { local h=${1%%:*} port=$((16#${1##*:})); local ip=""
  if [ ${#h} -eq 8 ]; then ip="$((16#${h:6:2})).$((16#${h:4:2})).$((16#${h:2:2})).$((16#${h:0:2}))"; else ip="[v6:$h]"; fi
  echo "$ip:$port"; }
for p in tcp tcp6 udp udp6; do
  adb shell cat /proc/net/$p | tr -d '\r' | tail -n +2 | while read -r sl la ra st _ _ _ uid _; do
    case $st in 01) s=ESTABLISHED;; 0A) s=LISTEN;; 06) s=TIME_WAIT;; 08) s=CLOSE_WAIT;; 02) s=SYN_SENT;; *) s=$st;; esac
    echo "$ts,$p,$(hex2ip $la),$(hex2ip $ra),$s,$uid,${pk[$uid]:-uid_$uid}"
  done >> "$out"
done
echo "wrote $out ($(($(wc -l < "$out")-1)) rows)"
