#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <change-id> <memory-generation|archive|branch-finish> <completed|blocked> [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
STAGE="$2"
RESULT="$3"
PROJECT_ROOT="${4:-$PWD}"
STATE_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/current-workflow-state.md"

UPDATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"
APPEND_AUDIT_SCRIPT="$ROOT_DIR/scripts/append-audit-log.sh"

case "$STAGE" in
  memory-generation|archive|branch-finish)
    ;;
  *)
    echo "Unsupported finalization stage: $STAGE" >&2
    exit 1
    ;;
esac

case "$RESULT" in
  completed|blocked)
    ;;
  *)
    echo "Unsupported result: $RESULT" >&2
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

CURRENT_STAGE="$(get_field "$STATE_FILE" finalization_stage)"
MODE="$(get_field "$STATE_FILE" execution_mode)"
TOOL="$(get_field "$STATE_FILE" external_tool)"

if [[ "$CURRENT_STAGE" != "$STAGE" ]]; then
  echo "Current finalization_stage mismatch: expected=$CURRENT_STAGE got=$STAGE" >&2
  exit 1
fi

FIELD_NAME="${STAGE//-/_}_status"

if [[ "$RESULT" == "blocked" ]]; then
  "$UPDATE_SCRIPT" "$CHANGE_ID" workflow "$FIELD_NAME" "blocked" "$PROJECT_ROOT"
  "$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "await-user-finalization-resolution" "$PROJECT_ROOT"
  "$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "finalization_blocked:$STAGE" "$PROJECT_ROOT"
  NEXT_ACTION="await-user-finalization-resolution"
  APPEND_RESULT="BLOCKED"
else
  "$UPDATE_SCRIPT" "$CHANGE_ID" workflow "$FIELD_NAME" "completed" "$PROJECT_ROOT"
  case "$STAGE" in
    memory-generation)
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow finalization_stage "archive" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow archive_status "in_progress" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "dispatch-archive-subagent" "$PROJECT_ROOT"
      NEXT_ACTION="dispatch-archive-subagent"
      ;;
    archive)
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow finalization_stage "branch-finish" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow branch_finish_status "in_progress" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "dispatch-branch-finish-subagent" "$PROJECT_ROOT"
      NEXT_ACTION="dispatch-branch-finish-subagent"
      ;;
    branch-finish)
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow finalization_stage "done" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "workflow-complete" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "finalization_completed" "$PROJECT_ROOT"
      NEXT_ACTION="workflow-complete"
      ;;
  esac
  APPEND_RESULT="COMPLETED"
fi

"$APPEND_AUDIT_SCRIPT" \
  "$CHANGE_ID" \
  "finalization" \
  "${MODE:-UNSET}" \
  "${TOOL:-UNSET}" \
  "complete finalization stage $STAGE" \
  "$APPEND_RESULT" \
  "$NEXT_ACTION" \
  "$PROJECT_ROOT"

echo "finalization_stage_handled: $STAGE"
echo "result: $RESULT"
echo "next_action: $NEXT_ACTION"
