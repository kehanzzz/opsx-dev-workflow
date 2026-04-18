#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <change-id> <APPROVED|CHANGES_REQUESTED|BLOCKED> <feedback-summary> [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
REVIEW_RESULT="$2"
FEEDBACK_SUMMARY="$3"
PROJECT_ROOT="${4:-$PWD}"
STATE_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/current-workflow-state.md"
TASK_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/current-task.md"

UPDATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"
ADVANCE_PHASE_SCRIPT="$ROOT_DIR/scripts/advance-phase.sh"
APPEND_AUDIT_SCRIPT="$ROOT_DIR/scripts/append-audit-log.sh"

case "$REVIEW_RESULT" in
  APPROVED|CHANGES_REQUESTED|BLOCKED)
    ;;
  *)
    echo "Unsupported review result: $REVIEW_RESULT" >&2
    exit 1
    ;;
esac

if [[ ! -f "$STATE_FILE" || ! -f "$TASK_FILE" ]]; then
  echo "Missing workflow-state files for change: $CHANGE_ID" >&2
  exit 1
fi

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

get_field() {
  local file="$1"
  local field="$2"
  sed -n "s/^- \`${field}\`: \`\\(.*\\)\`$/\\1/p" "$file" | head -n 1
}

MODE="$(get_field "$STATE_FILE" execution_mode)"
TOOL="$(get_field "$STATE_FILE" external_tool)"
CURRENT_ROUND="$(get_field "$STATE_FILE" review_round)"
MAX_ROUNDS="$(get_field "$STATE_FILE" review_max_rounds)"
COMPLETED_AT="$(timestamp)"

"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_completed_at "$COMPLETED_AT" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_feedback "$FEEDBACK_SUMMARY" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" task review_status "$REVIEW_RESULT" "$PROJECT_ROOT"

case "$REVIEW_RESULT" in
  APPROVED)
    "$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_loop_status "approved" "$PROJECT_ROOT"
    "$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "auto_phase_55_approved:round=$CURRENT_ROUND" "$PROJECT_ROOT"
    "$UPDATE_SCRIPT" "$CHANGE_ID" task next_action "openspec-verify-change" "$PROJECT_ROOT"
    "$ADVANCE_PHASE_SCRIPT" "$CHANGE_ID" "verification" "openspec-verify-change" "$PROJECT_ROOT"
    NEXT_ACTION="openspec-verify-change"
    ;;
  CHANGES_REQUESTED)
    if [[ "$CURRENT_ROUND" =~ ^[0-9]+$ && "$MAX_ROUNDS" =~ ^[0-9]+$ && "$CURRENT_ROUND" -lt "$MAX_ROUNDS" ]]; then
      NEXT_ACTION="auto-fix-review-feedback-round-$CURRENT_ROUND"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_loop_status "repairing" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "$NEXT_ACTION" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "auto_phase_55_repairing:round=$CURRENT_ROUND" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" task next_action "$NEXT_ACTION" "$PROJECT_ROOT"
    else
      NEXT_ACTION="await-user-review-resolution"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_loop_status "manual_intervention_required" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "$NEXT_ACTION" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "auto_phase_55_manual_intervention:round=$CURRENT_ROUND" "$PROJECT_ROOT"
      "$UPDATE_SCRIPT" "$CHANGE_ID" task next_action "$NEXT_ACTION" "$PROJECT_ROOT"
    fi
    ;;
  BLOCKED)
    NEXT_ACTION="await-user-review-resolution"
    "$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_loop_status "manual_intervention_required" "$PROJECT_ROOT"
    "$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "$NEXT_ACTION" "$PROJECT_ROOT"
    "$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "auto_phase_55_blocked:round=$CURRENT_ROUND" "$PROJECT_ROOT"
    "$UPDATE_SCRIPT" "$CHANGE_ID" task next_action "$NEXT_ACTION" "$PROJECT_ROOT"
    ;;
esac

"$APPEND_AUDIT_SCRIPT" \
  "$CHANGE_ID" \
  "code-review" \
  "${MODE:-UNSET}" \
  "${TOOL:-UNSET}" \
  "handle code review result round ${CURRENT_ROUND:-UNSET}" \
  "$REVIEW_RESULT" \
  "$NEXT_ACTION" \
  "$PROJECT_ROOT"

echo "review_result_handled: $REVIEW_RESULT"
echo "next_action: $NEXT_ACTION"
