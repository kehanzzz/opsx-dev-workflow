#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <change-id> <phase> <next-action> [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
PHASE="$2"
NEXT_ACTION="$3"
PROJECT_ROOT="${4:-$PWD}"
UPDATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"

"$UPDATE_SCRIPT" "$CHANGE_ID" workflow current_phase "$PHASE" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "$NEXT_ACTION" "$PROJECT_ROOT"

echo "phase_advanced: $PHASE"
