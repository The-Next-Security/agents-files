#!/usr/bin/env bash
# test-daily-format.sh
#
# Validates that a sample daily report conforms to the canonical
# structure defined in references/daily-format.md.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <path-to-daily-file>" >&2
  exit 2
fi

FILE="$1"
if [[ ! -f "$FILE" ]]; then
  echo "daily file not found: $FILE" >&2
  exit 3
fi

REQUIRED_HEADERS=(
  "Daily stand-up"
  "== Product Owner =="
  "== QA Analyst =="
  "== Frontend Developer =="
  "== Backend Developer =="
  "== UX Developer =="
  "== Git Expert =="
  "== Docs Expert =="
  "== Node/TS Specialist =="
  "== Debugger Agent =="
  "== Sprint health =="
)

missing=0
for h in "${REQUIRED_HEADERS[@]}"; do
  if ! grep -qF -- "$h" "$FILE"; then
    echo "missing header: $h" >&2
    missing=$((missing + 1))
  fi
done

lines=$(wc -l < "$FILE")
if [[ "$lines" -gt 40 ]]; then
  echo "WARNING: daily has ${lines} lines (target max 40)" >&2
fi

if [[ "$missing" -eq 0 ]]; then
  echo "OK: daily format is valid (${lines} lines)"
  exit 0
fi

echo "FAIL: ${missing} header(s) missing" >&2
exit 1
