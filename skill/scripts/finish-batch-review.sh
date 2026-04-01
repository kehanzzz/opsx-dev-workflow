#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 7 ]]; then
  echo "Usage: $0 <change-id> <batch-status> <next-phase> <mode> <tool> <review-action> <next-action> [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
BATCH_STATUS="$2"
NEXT_PHASE="$3"
MODE="$4"
TOOL="$5"
REVIEW_ACTION="$6"
NEXT_ACTION="$7"
PROJECT_ROOT="${8:-$PWD}"

UPDATE_STATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"
ADVANCE_PHASE_SCRIPT="$ROOT_DIR/scripts/advance-phase.sh"
APPEND_AUDIT_SCRIPT="$ROOT_DIR/scripts/append-audit-log.sh"

case "$BATCH_STATUS" in
  APPROVED|CHANGES_REQUESTED|BLOCKED)
    ;;
  *)
    echo "Unsupported batch-status: $BATCH_STATUS" >&2
    exit 1
    ;;
esac

"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow notes "batch_review:$BATCH_STATUS" "$PROJECT_ROOT"
"$ADVANCE_PHASE_SCRIPT" "$CHANGE_ID" "$NEXT_PHASE" "$NEXT_ACTION" "$PROJECT_ROOT"
"$APPEND_AUDIT_SCRIPT" "$CHANGE_ID" "$NEXT_PHASE" "$MODE" "$TOOL" "$REVIEW_ACTION" "$BATCH_STATUS" "$NEXT_ACTION" "$PROJECT_ROOT"

echo "batch_review_finished: $BATCH_STATUS"
echo "next_phase: $NEXT_PHASE"
