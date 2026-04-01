#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <change-id> <task-id> <task-goal> <next-action> [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
TASK_ID="$2"
TASK_GOAL="$3"
NEXT_ACTION="$4"
PROJECT_ROOT="${5:-$PWD}"
UPDATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"

"$UPDATE_SCRIPT" "$CHANGE_ID" workflow current_task_id "$TASK_ID" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "$NEXT_ACTION" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" task task_id "$TASK_ID" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" task task_goal "$TASK_GOAL" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" task next_action "$NEXT_ACTION" "$PROJECT_ROOT"

echo "current_task_synced: $TASK_ID"
