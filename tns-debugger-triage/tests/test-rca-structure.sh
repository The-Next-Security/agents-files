#!/usr/bin/env bash
# test-rca-structure.sh
#
# Validates that a generated RCA file has the required sections.
# Intended to be run against a sample RCA produced from a synthetic
# issue or during dry-run testing of the skill.
#
# Usage: test-rca-structure.sh <path-to-rca-file>

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <path-to-rca-file>" >&2
  exit 2
fi

FILE="$1"
if [[ ! -f "$FILE" ]]; then
  echo "RCA file not found: $FILE" >&2
  exit 3
fi

REQUIRED=(
  "# RCA"
  "## Metadata"
  "## Síntoma observado"
  "## Reproducción determinística"
  "## Root cause identificado"
  "## Commit culpable"
  "## Propuesta de fix"
  "## Riesgo de regresión del fix"
  "## Asignación sugerida"
  "## Evidencia adjunta"
)

missing=0
for section in "${REQUIRED[@]}"; do
  if ! grep -q -- "$section" "$FILE"; then
    echo "missing section: $section" >&2
    missing=$((missing + 1))
  fi
done

if [[ "$missing" -eq 0 ]]; then
  echo "OK: RCA structure is complete"
  exit 0
fi

echo "FAIL: $missing section(s) missing" >&2
exit 1
