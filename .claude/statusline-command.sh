#!/bin/sh
input=$(cat)
branch=$(git -C "$(echo "$input" | jq -r '.workspace.current_dir // "."')" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
model=$(echo "$input" | jq -r 'if .model.display_name != null and .model.display_name != "" then .model.display_name elif .model.id != null and .model.id != "" then .model.id else "Unknown" end')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
rate=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // .rate_limits.seven_day.used_percentage // empty')

if [ -n "$used" ]; then
  ctx=$(printf "ctx:%.0f%%" "$used")
else
  ctx="ctx:--"
fi

if [ -n "$rate" ]; then
  rate_str=$(printf "rate:%.0f%%" "$rate")
else
  rate_str=""
fi

out=""
[ -n "$branch" ] && out="$branch"
[ -n "$out" ] && out="$out | $model" || out="$model"
out="$out | $ctx"
[ -n "$rate_str" ] && out="$out | $rate_str"

printf "%s" "$out"
