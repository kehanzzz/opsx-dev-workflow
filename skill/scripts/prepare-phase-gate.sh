#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <change-id> <finalization> <execute-action> [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
TARGET_PHASE="$2"
EXECUTE_ACTION="$3"
PROJECT_ROOT="${4:-$PWD}"
STATE_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/current-workflow-state.md"

UPDATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"
APPEND_AUDIT_SCRIPT="$ROOT_DIR/scripts/append-audit-log.sh"

case "$TARGET_PHASE" in
  finalization)
    ;;
  *)
    echo "Unsupported gated phase: $TARGET_PHASE" >&2
    exit 1
    ;;
esac

if [[ ! -f "$STATE_FILE" ]]; then
  echo "Missing state file: $STATE_FILE" >&2
  exit 1
fi

get_field() {
  local file="$1"
  local field="$2"
  sed -n "s/^- \`${field}\`: \`\\(.*\\)\`$/\\1/p" "$file" | head -n 1
}

EXECUTION_MODE="$(get_field "$STATE_FILE" execution_mode)"
EXTERNAL_TOOL="$(get_field "$STATE_FILE" external_tool)"
GATE_PHASE="${TARGET_PHASE}-approval"
NEXT_ACTION="await-user-approval"
NOTES="pending_gate:${TARGET_PHASE}; execute_action:${EXECUTE_ACTION}"

"$UPDATE_SCRIPT" "$CHANGE_ID" workflow current_phase "$GATE_PHASE" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "$NEXT_ACTION" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "$NOTES" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow checkpoint_status "pending" "$PROJECT_ROOT"

"$APPEND_AUDIT_SCRIPT" \
  "$CHANGE_ID" \
  "$GATE_PHASE" \
  "${EXECUTION_MODE:-UNSET}" \
  "${EXTERNAL_TOOL:-UNSET}" \
  "prepare gate for $TARGET_PHASE" \
  "PENDING_APPROVAL" \
  "$NEXT_ACTION" \
  "$PROJECT_ROOT"

echo "gate_prepared: $GATE_PHASE"
echo "execute_action: $EXECUTE_ACTION"
