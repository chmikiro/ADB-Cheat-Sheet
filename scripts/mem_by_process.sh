#!/usr/bin/env bash
out="${1:-mem_by_process_$(date +%Y%m%d_%H%M%S).csv}"
ts=$(date -Iseconds)
echo "timestamp,pss_kb,process,pid,state" > "$out"
adb shell dumpsys meminfo | tr -d '\r' | awk -v ts="$ts" '
/^Total PSS by process:/ {on=1; next}
/^Total PSS by OOM adjustment:/ {on=0}
on && /K: / {
  line=$0; gsub(/^ +/,"",line)
  split(line,a,"K: "); pss=a[1]; gsub(/,/,"",pss)
  rest=a[2]; proc=rest; sub(/ \(pid .*/,"",proc)
  pid=rest; sub(/.*\(pid /,"",pid); sub(/[ )].*/,"",pid)
  st=""; if (rest ~ /\/ /) { st=rest; sub(/.*\/ /,"",st); sub(/\)$/,"",st) }
  printf "%s,%s,%s,%s,%s\n", ts, pss, proc, pid, st
}' >> "$out"
echo "wrote $out ($(($(wc -l < "$out")-1)) rows)"
