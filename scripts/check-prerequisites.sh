#!/usr/bin/env bash
set -euo pipefail

for cmd in git bash python3 rg; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing dependency: $cmd" >&2
    exit 1
  fi
done

echo "prerequisites: OK"
