#!/usr/bin/env bash
out="${1:-alarms_$(date +%Y%m%d_%H%M%S).csv}"
echo "package,pending_alarms" > "$out"
adb shell dumpsys alarm | tr -d '\r' > "${out%.csv}.raw.txt"
grep -E "^ +(RTC_WAKEUP|ELAPSED_WAKEUP|RTC|ELAPSED) #[0-9]+: Alarm" "${out%.csv}.raw.txt" \
 | sed -E 's/.*(RTC_WAKEUP|ELAPSED_WAKEUP|RTC|ELAPSED) #[0-9]+: Alarm\{[^ ]+ type [0-9]+ [a-z]* ?([A-Za-z0-9_.]+)\}.*/\2/' \
 | sort | uniq -c | sort -rn | awk '{print $2","$1}' >> "$out"
echo "wrote $out, ${out%.csv}.raw.txt"
