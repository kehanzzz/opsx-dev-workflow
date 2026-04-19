#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <script-name> [args...]" >&2
  exit 1
fi

SCRIPT_NAME="$1"
shift

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$ROOT_DIR/skill/scripts/$SCRIPT_NAME"

if [[ ! -f "$TARGET" ]]; then
  echo "Missing skill script: $TARGET" >&2
  exit 1
fi

exec bash "$TARGET" "$@"
