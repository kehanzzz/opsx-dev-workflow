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
TEMPLATE_FILE="$ROOT_DIR/prompts/memory-generation-subagent.md"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Template file missing: $TEMPLATE_FILE" >&2
  exit 1
fi

PROJECT_ROOT="$(bash "$SCRIPT_DIR/get-project-root.sh" "$PROJECT_ROOT")"
CHANGE_DIR="$PROJECT_ROOT/openspec/changes/$CHANGE_ID"
WORKFLOW_STATE_DIR="$CHANGE_DIR/workflow-state"
DOCS_DIR="$PROJECT_ROOT/docs"

if [[ ! -d "$WORKFLOW_STATE_DIR" ]]; then
  echo "Workflow state directory missing: $WORKFLOW_STATE_DIR" >&2
  exit 1
fi

get_field() {
  local file="$1"
  local field="$2"
  sed -n "s/^- \`${field}\`: \`\\(.*\\)\`$/\\1/p" "$file" | head -n 1
}

normalize_field() {
  local value="$1"
  if [[ -z "$value" || "$value" == "UNSET" ]]; then
    printf '%s' "(none recorded)"
  else
    printf '%s' "$value"
  fi
}

CURRENT_BRANCH="$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD)"
MAIN_BRANCH="$(git -C "$PROJECT_ROOT" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)"
if [[ -z "$MAIN_BRANCH" || "$MAIN_BRANCH" == "HEAD" || "$MAIN_BRANCH" == "origin/HEAD" ]]; then
  if git -C "$PROJECT_ROOT" show-ref --verify --quiet refs/heads/main; then
    MAIN_BRANCH="main"
  elif git -C "$PROJECT_ROOT" show-ref --verify --quiet refs/heads/master; then
    MAIN_BRANCH="master"
  else
    MAIN_BRANCH="main"
  fi
fi

STATE_FILE="$WORKFLOW_STATE_DIR/current-workflow-state.md"
WORKFLOW_NOTES="$(normalize_field "$(get_field "$STATE_FILE" notes)")"
CHECKPOINT_FEEDBACK="$(normalize_field "$(get_field "$STATE_FILE" checkpoint_feedback)")"
REVIEW_FEEDBACK="$(normalize_field "$(get_field "$STATE_FILE" review_feedback)")"

rendered="$(
  sed \
    -e "s|{CHANGE_ID}|$CHANGE_ID|g" \
    -e "s|{PROJECT_ROOT}|$PROJECT_ROOT|g" \
    -e "s|{DOCS_DIR}|$DOCS_DIR|g" \
    -e "s|{WORKFLOW_STATE_DIR}|$WORKFLOW_STATE_DIR|g" \
    -e "s|{CHANGE_DIR}|$CHANGE_DIR|g" \
    -e "s|{MAIN_BRANCH}|$MAIN_BRANCH|g" \
    -e "s|{CURRENT_BRANCH}|$CURRENT_BRANCH|g" \
    -e "s|{SCRIPT_DIR}|$SCRIPT_DIR|g" \
    "$TEMPLATE_FILE"
)"

rendered="$(printf '%s\n\n## Conversation-Derived Signals\n\n- workflow notes: %s\n- checkpoint feedback: %s\n- review feedback: %s\n' \
  "$rendered" \
  "$WORKFLOW_NOTES" \
  "$CHECKPOINT_FEEDBACK" \
  "$REVIEW_FEEDBACK")"

if [[ -n "$OUTPUT_FILE" ]]; then
  printf '%s\n' "$rendered" > "$OUTPUT_FILE"
  echo "rendered_prompt: $OUTPUT_FILE"
else
  printf '%s\n' "$rendered"
fi
