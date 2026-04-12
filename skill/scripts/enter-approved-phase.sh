#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <change-id> <archive|branch-finish> <execute-action> [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
TARGET_PHASE="$2"
EXECUTE_ACTION="$3"
PROJECT_ROOT="${4:-$PWD}"
STATE_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/current-workflow-state.md"

ADVANCE_PHASE_SCRIPT="$ROOT_DIR/scripts/advance-phase.sh"
UPDATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"
APPEND_AUDIT_SCRIPT="$ROOT_DIR/scripts/append-audit-log.sh"

case "$TARGET_PHASE" in
  archive|branch-finish)
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

CURRENT_PHASE="$(get_field "$STATE_FILE" current_phase)"
EXECUTION_MODE="$(get_field "$STATE_FILE" execution_mode)"
EXTERNAL_TOOL="$(get_field "$STATE_FILE" external_tool)"
EXPECTED_PHASE="${TARGET_PHASE}-approval"

if [[ "$CURRENT_PHASE" != "$EXPECTED_PHASE" ]]; then
  echo "Current phase must be $EXPECTED_PHASE before approval entry: $CURRENT_PHASE" >&2
  exit 1
fi

"$UPDATE_SCRIPT" "$CHANGE_ID" workflow checkpoint_status "approved" "$PROJECT_ROOT"
"$ADVANCE_PHASE_SCRIPT" "$CHANGE_ID" "$TARGET_PHASE" "$EXECUTE_ACTION" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "gate_approved:${TARGET_PHASE}; execute_action:${EXECUTE_ACTION}" "$PROJECT_ROOT"

"$APPEND_AUDIT_SCRIPT" \
  "$CHANGE_ID" \
  "$TARGET_PHASE" \
  "${EXECUTION_MODE:-UNSET}" \
  "${EXTERNAL_TOOL:-UNSET}" \
  "approval granted for $TARGET_PHASE" \
  "APPROVED" \
  "$EXECUTE_ACTION" \
  "$PROJECT_ROOT"

echo "entered_phase: $TARGET_PHASE"
echo "next_action: $EXECUTE_ACTION"
