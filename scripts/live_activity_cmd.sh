#!/usr/bin/env bash
adb logcat -v brief ActivityTaskManager:I ActivityManager:I *:S | awk '
/act=android.intent.action.MAIN/ && /cmp=/ { match($0,/cmp=[^ ]+/); c=substr($0,RSTART+4,RLENGTH-4); print "adb shell am start -n " c }'
