#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <change-id> [project-root]" >&2
  exit 1
fi

CHANGE_ID="$1"
PROJECT_ROOT="${2:-$PWD}"
STATE_DIR="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state"
STATE_FILE="$STATE_DIR/current-workflow-state.md"
PLAN_FILE="$STATE_DIR/current-plan.md"
TASK_FILE="$STATE_DIR/current-task.md"

required_files=("$STATE_FILE" "$PLAN_FILE" "$TASK_FILE")

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing state file: $file" >&2
    exit 1
  fi
done

for key in current_phase execution_mode next_action; do
  if ! rg -q --fixed-strings "\`$key\`:" "$STATE_FILE"; then
    echo "State file missing field: $key" >&2
    exit 1
  fi
done

echo "workflow-state: OK"
echo "state_dir: $STATE_DIR"
echo "state_file: $STATE_FILE"
echo "plan_file: $PLAN_FILE"
echo "task_file: $TASK_FILE"
