#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 5 ]]; then
  echo "Usage: $0 <change-id> <execution-mode> <external-tool> <next-action> <audit-action> [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
EXECUTION_MODE="$2"
EXTERNAL_TOOL="$3"
NEXT_ACTION="$4"
AUDIT_ACTION="$5"
PROJECT_ROOT="${6:-$PWD}"

ADVANCE_PHASE_SCRIPT="$ROOT_DIR/scripts/advance-phase.sh"
UPDATE_STATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"
APPEND_AUDIT_SCRIPT="$ROOT_DIR/scripts/append-audit-log.sh"

"$ADVANCE_PHASE_SCRIPT" "$CHANGE_ID" "execute-plan" "$NEXT_ACTION" "$PROJECT_ROOT"
"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow execution_mode "$EXECUTION_MODE" "$PROJECT_ROOT"
"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow external_tool "$EXTERNAL_TOOL" "$PROJECT_ROOT"
"$APPEND_AUDIT_SCRIPT" "$CHANGE_ID" "execute-plan" "$EXECUTION_MODE" "$EXTERNAL_TOOL" "$AUDIT_ACTION" "STARTED" "$NEXT_ACTION" "$PROJECT_ROOT"

echo "execution_mode_started: $EXECUTION_MODE"
echo "external_tool: $EXTERNAL_TOOL"
