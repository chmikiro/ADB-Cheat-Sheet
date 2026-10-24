#!/usr/bin/env bash
out="${1:-privacy_audit_$(date +%Y%m%d_%H%M%S).csv}"
echo "package,installer,targetSdk,dangerous_granted,run_in_background" > "$out"
for p in $(adb shell pm list packages -3 | tr -d '\r' | cut -d: -f2); do
  dump=$(adb shell dumpsys package "$p" | tr -d '\r')
  inst=$(echo "$dump" | awk -F= '/installerPackageName=/{print $2; exit}')
  tsdk=$(echo "$dump" | awk -F= '/targetSdk=/{split($2,a," "); print a[1]; exit}')
  perms=$(echo "$dump" | grep -E "android.permission\.(CAMERA|RECORD_AUDIO|ACCESS_(FINE|COARSE|BACKGROUND)_LOCATION|READ_CONTACTS|READ_SMS|READ_CALL_LOG|READ_PHONE_STATE|READ_EXTERNAL_STORAGE|POST_NOTIFICATIONS).*granted=true" | sed -E 's/^ +android.permission.([A-Z_]+).*/\1/' | sort -u | paste -sd'|')
  bg=$(adb shell cmd appops get "$p" RUN_IN_BACKGROUND 2>/dev/null | tr -d '\r' | head -1 | sed 's/.*: //;s/;.*//')
  echo "$p,${inst:-unknown},${tsdk:-?},\"${perms}\",\"${bg}\"" >> "$out"
done
echo "wrote $out"
