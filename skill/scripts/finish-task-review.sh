#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 7 ]]; then
  echo "Usage: $0 <change-id> <review-status> <task-status> <mode> <tool> <review-action> <next-action> [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
REVIEW_STATUS="$2"
TASK_STATUS="$3"
MODE="$4"
TOOL="$5"
REVIEW_ACTION="$6"
NEXT_ACTION="$7"
PROJECT_ROOT="${8:-$PWD}"

UPDATE_STATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"
APPEND_AUDIT_SCRIPT="$ROOT_DIR/scripts/append-audit-log.sh"

case "$REVIEW_STATUS" in
  APPROVED|CHANGES_REQUESTED|BLOCKED)
    ;;
  *)
    echo "Unsupported review-status: $REVIEW_STATUS" >&2
    exit 1
    ;;
esac

"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" task review_status "$REVIEW_STATUS" "$PROJECT_ROOT"
"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" task task_status "$TASK_STATUS" "$PROJECT_ROOT"
"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" task next_action "$NEXT_ACTION" "$PROJECT_ROOT"
"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow next_action "$NEXT_ACTION" "$PROJECT_ROOT"
"$APPEND_AUDIT_SCRIPT" "$CHANGE_ID" "execute-plan" "$MODE" "$TOOL" "$REVIEW_ACTION" "$REVIEW_STATUS" "$NEXT_ACTION" "$PROJECT_ROOT"

echo "task_review_finished: $REVIEW_STATUS"
echo "task_status: $TASK_STATUS"
