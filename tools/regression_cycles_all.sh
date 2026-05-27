#!/usr/bin/env bash
set -euo pipefail

SUBMODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Prefer superproject root when this is a git submodule checkout.
SUPER_ROOT="$(cd "$SUBMODULE_DIR" && git rev-parse --show-superproject-working-tree 2>/dev/null || true)"
if [[ -n "$SUPER_ROOT" ]]; then
  ROOT_DIR="$SUPER_ROOT"
else
  ROOT_DIR="$SUBMODULE_DIR"
fi

cd "$ROOT_DIR"

if [[ ! -f "scripts/run_test.py" ]]; then
  echo "ERROR: scripts/run_test.py nicht gefunden."
  echo "Hinweis: Dieses Skript erwartet den Superprojekt-Workspace mit tests/ und scripts/."
  exit 2
fi

AU=16
DATE_TAG="$(date +%Y%m%d_%H%M%S)"
REPORT_DIR="${REPORT_DIR:-$ROOT_DIR/build/reports}"
REPORT_CSV="$REPORT_DIR/cycle_regression_${DATE_TAG}.csv"

mkdir -p "$REPORT_DIR"

if [[ ! -f "$ROOT_DIR/.venv/bin/activate" ]]; then
  echo "ERROR: .venv fehlt. Bitte zuerst: python3 -m venv .venv && . .venv/bin/activate && pip install numpy"
  exit 2
fi

# shellcheck disable=SC1091
. "$ROOT_DIR/.venv/bin/activate"

if ! docker ps --format '{{.Names}}' | grep -qx 'vspa-unified'; then
  echo "[info] starte vspa-unified..."
  docker compose up -d vspa-unified
fi

if ! docker exec vspa-unified python3 -c 'import numpy' >/dev/null 2>&1; then
  echo "[info] installiere numpy im Container..."
  docker exec vspa-unified python3 -m pip install numpy >/dev/null
fi

mapfile -t kernels < <(find tests -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

if [[ ${#kernels[@]} -eq 0 ]]; then
  echo "ERROR: keine tests/<kernel>-Ordner gefunden"
  exit 2
fi

echo "kernel,status,cycles" > "$REPORT_CSV"

pass_count=0
fail_count=0

for k in "${kernels[@]}"; do
  if [[ ! -f "tests/$k/Makefile" ]]; then
    continue
  fi

  echo "===== $k ====="
  out="$(python scripts/run_test.py --kernel "$k" --au "$AU" --cycles 2>&1 || true)"
  if echo "$out" | grep -q 'RESULT : PASS'; then
    c="$(echo "$out" | sed -n 's/.*RESULT : PASS ✓  (\([0-9][0-9]*\) cycles).*/\1/p' | tail -n1)"
    if [[ -n "$c" ]]; then
      echo "  PASS cycles=$c"
      echo "$k,PASS,$c" >> "$REPORT_CSV"
      pass_count=$((pass_count+1))
    else
      echo "  FAIL (kein cycle-wert parsebar)"
      echo "$k,FAIL," >> "$REPORT_CSV"
      fail_count=$((fail_count+1))
    fi
  else
    echo "  FAIL"
    echo "$out" | tail -n 12
    echo "$k,FAIL," >> "$REPORT_CSV"
    fail_count=$((fail_count+1))
  fi

  echo

done

echo "Report: $REPORT_CSV"
echo "PASS: $pass_count"
echo "FAIL: $fail_count"

if [[ $fail_count -gt 0 ]]; then
  exit 1
fi
