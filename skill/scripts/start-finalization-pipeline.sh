#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <change-id> [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
PROJECT_ROOT="${2:-$PWD}"
STATE_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/current-workflow-state.md"

UPDATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"
APPEND_AUDIT_SCRIPT="$ROOT_DIR/scripts/append-audit-log.sh"

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
MODE="$(get_field "$STATE_FILE" execution_mode)"
TOOL="$(get_field "$STATE_FILE" external_tool)"

if [[ "$CURRENT_PHASE" != "finalization" ]]; then
  echo "start-finalization-pipeline requires current_phase=finalization: $CURRENT_PHASE" >&2
  exit 1
fi

"$UPDATE_SCRIPT" "$CHANGE_ID" workflow finalization_stage "memory-generation" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow memory_generation_status "in_progress" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow archive_status "pending" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow branch_finish_status "pending" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "dispatch-memory-generation-subagent" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "finalization_pipeline_started" "$PROJECT_ROOT"

"$APPEND_AUDIT_SCRIPT" \
  "$CHANGE_ID" \
  "finalization" \
  "${MODE:-UNSET}" \
  "${TOOL:-UNSET}" \
  "start finalization pipeline" \
  "IN_PROGRESS" \
  "dispatch-memory-generation-subagent" \
  "$PROJECT_ROOT"

echo "finalization_pipeline_started: $CHANGE_ID"
echo "finalization_stage: memory-generation"
