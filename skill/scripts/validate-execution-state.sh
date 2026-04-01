#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <change-id> <mode> [project-root]" >&2
  exit 1
fi

CHANGE_ID="$1"
MODE="$2"
PROJECT_ROOT="${3:-$PWD}"
STATE_DIR="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state"
WORKFLOW_FILE="$STATE_DIR/current-workflow-state.md"

if [[ ! -f "$WORKFLOW_FILE" ]]; then
  echo "Missing state file: $WORKFLOW_FILE" >&2
  exit 1
fi

get_field() {
  local file="$1"
  local field="$2"
  sed -n "s/^- \`${field}\`: \`\\(.*\\)\`$/\\1/p" "$file" | head -n 1
}

current_phase="$(get_field "$WORKFLOW_FILE" current_phase)"
execution_mode="$(get_field "$WORKFLOW_FILE" execution_mode)"
external_tool="$(get_field "$WORKFLOW_FILE" external_tool)"
current_task_id="$(get_field "$WORKFLOW_FILE" current_task_id)"

if [[ "$current_phase" != "execute-plan" ]]; then
  echo "Current phase is not execute-plan: $current_phase" >&2
  exit 1
fi

if [[ "$execution_mode" != "$MODE" ]]; then
  echo "Execution mode mismatch: state=$execution_mode expected=$MODE" >&2
  exit 1
fi

if [[ -z "$external_tool" || "$external_tool" == "UNSET" ]]; then
  echo "external_tool is not set" >&2
  exit 1
fi

if [[ "$MODE" == "quality-first" && ( -z "$current_task_id" || "$current_task_id" == "UNSET" ) ]]; then
  echo "current_task_id is not set in quality-first mode" >&2
  exit 1
fi

echo "execution-state: OK"
echo "mode: $MODE"
echo "tool: $external_tool"
