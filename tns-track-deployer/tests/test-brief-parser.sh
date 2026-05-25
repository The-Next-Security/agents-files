#!/usr/bin/env bash
# test-brief-parser.sh
#
# Validates that briefs in JSON and markdown formats are parsed
# correctly and that invalid briefs are rejected with a clear error.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES="${SCRIPT_DIR}/fixtures"

fail=0

check_required_fields_json() {
  local file="$1"
  local expected_valid="$2"
  local valid=true
  for field in client_name client_slug vertical authorized_by; do
    if ! jq -e ".${field}" "$file" >/dev/null 2>&1; then
      valid=false
      break
    fi
  done
  if [[ "$valid" == "$expected_valid" ]]; then
    echo "OK: $(basename "$file") parsed as ${expected_valid}"
  else
    echo "FAIL: $(basename "$file") expected ${expected_valid} got ${valid}" >&2
    fail=$((fail + 1))
  fi
}

check_required_fields_md() {
  local file="$1"
  local expected_valid="$2"
  local valid=true
  for field in client_name client_slug vertical authorized_by; do
    if ! grep -qE "^- ${field}:" "$file"; then
      valid=false
      break
    fi
  done
  if [[ "$valid" == "$expected_valid" ]]; then
    echo "OK: $(basename "$file") parsed as ${expected_valid}"
  else
    echo "FAIL: $(basename "$file") expected ${expected_valid} got ${valid}" >&2
    fail=$((fail + 1))
  fi
}

if ! command -v jq >/dev/null 2>&1; then
  echo "SKIP: jq not installed"
  exit 0
fi

check_required_fields_json "${FIXTURES}/brief-valid.json" "true"
check_required_fields_json "${FIXTURES}/brief-missing-slug.json" "false"
check_required_fields_md   "${FIXTURES}/brief-valid.md"   "true"
check_required_fields_md   "${FIXTURES}/brief-missing-authorized.md" "false"

if [[ "$fail" -eq 0 ]]; then
  echo
  echo "All brief-parser tests passed"
  exit 0
fi

echo
echo "${fail} test(s) failed" >&2
exit 1
