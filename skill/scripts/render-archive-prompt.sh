#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <change-id> [project-root] [output-file]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CHANGE_ID="$1"
PROJECT_ROOT="${2:-$PWD}"
OUTPUT_FILE="${3:-}"
TEMPLATE_FILE="$ROOT_DIR/prompts/archive-subagent.md"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Template file missing: $TEMPLATE_FILE" >&2
  exit 1
fi

PROJECT_ROOT="$(bash "$SCRIPT_DIR/get-project-root.sh" "$PROJECT_ROOT")"
CHANGE_DIR="$PROJECT_ROOT/openspec/changes/$CHANGE_ID"
WORKFLOW_STATE_DIR="$CHANGE_DIR/workflow-state"

if [[ ! -d "$WORKFLOW_STATE_DIR" ]]; then
  echo "Workflow state directory missing: $WORKFLOW_STATE_DIR" >&2
  exit 1
fi

CURRENT_BRANCH="$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD)"

rendered="$(
  sed \
    -e "s|{CHANGE_ID}|$CHANGE_ID|g" \
    -e "s|{PROJECT_ROOT}|$PROJECT_ROOT|g" \
    -e "s|{WORKFLOW_STATE_DIR}|$WORKFLOW_STATE_DIR|g" \
    -e "s|{CHANGE_DIR}|$CHANGE_DIR|g" \
    -e "s|{CURRENT_BRANCH}|$CURRENT_BRANCH|g" \
    "$TEMPLATE_FILE"
)"

if [[ -n "$OUTPUT_FILE" ]]; then
  printf '%s\n' "$rendered" > "$OUTPUT_FILE"
  echo "rendered_prompt: $OUTPUT_FILE"
else
  printf '%s\n' "$rendered"
fi
