#!/usr/bin/env bash
d="diag_$(date +%Y%m%d_%H%M%S)"; mkdir -p "$d"
for s in meminfo procstats cpuinfo batterystats battery alarm jobscheduler deviceidle connectivity netstats netpolicy wifi \
         activity package appops location notification usagestats diskstats thermalservice power window display telephony.registry; do
  adb shell dumpsys "$s" > "$d/dumpsys_$s.txt" 2>&1
done
adb shell getprop > "$d/getprop.txt"
adb shell cat /proc/meminfo > "$d/proc_meminfo.txt"
adb shell cat /proc/net/tcp > "$d/proc_net_tcp.txt"; adb shell cat /proc/net/tcp6 > "$d/proc_net_tcp6.txt"
adb shell cat /proc/net/udp > "$d/proc_net_udp.txt"
adb shell ip addr > "$d/ip_addr.txt"; adb shell ip route show table all > "$d/ip_route.txt"; adb shell ip rule > "$d/ip_rule.txt"
adb shell "netstat -tunap 2>/dev/null || ss -tunap" > "$d/netstat.txt" 2>&1
adb shell df -h > "$d/df.txt"; adb shell mount > "$d/mount.txt"
adb logcat -d -b all -v threadtime > "$d/logcat_all.txt"
adb shell pm list packages -f -i -U > "$d/packages.txt"
tar czf "$d.tar.gz" "$d" && echo "bundle: $d.tar.gz"
