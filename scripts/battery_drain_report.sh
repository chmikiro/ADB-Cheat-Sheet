#!/usr/bin/env bash
m="${1:-30}"; d="battery_$(date +%Y%m%d_%H%M%S)"; mkdir -p "$d"
adb shell dumpsys battery unplug >/dev/null 2>&1
adb shell dumpsys batterystats --reset >/dev/null
echo "Collecting for ${m} min..."; sleep $((m*60))
adb shell dumpsys batterystats > "$d/batterystats.txt"
adb shell dumpsys batterystats --checkin > "$d/batterystats.checkin"
adb shell dumpsys battery > "$d/battery.txt"
adb shell dumpsys battery reset >/dev/null 2>&1
echo "bundle: $d/"
