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
TASK_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/current-task.md"

UPDATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"
APPEND_AUDIT_SCRIPT="$ROOT_DIR/scripts/append-audit-log.sh"

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

CURRENT_ROUND="$(get_field "$STATE_FILE" review_round)"
MAX_ROUNDS="$(get_field "$STATE_FILE" review_max_rounds)"
PREV_HEAD_SHA="$(get_field "$STATE_FILE" review_head_sha)"
MODE="$(get_field "$STATE_FILE" execution_mode)"
TOOL="$(get_field "$STATE_FILE" external_tool)"

if ! [[ "$CURRENT_ROUND" =~ ^[0-9]+$ && "$MAX_ROUNDS" =~ ^[0-9]+$ ]]; then
  echo "review_round and review_max_rounds must be initialized before continuing" >&2
  exit 1
fi

if [[ -z "$PREV_HEAD_SHA" || "$PREV_HEAD_SHA" == "UNSET" ]]; then
  echo "review_head_sha must be initialized before continuing" >&2
  exit 1
fi

NEXT_ROUND=$((CURRENT_ROUND + 1))
if [[ "$NEXT_ROUND" -gt "$MAX_ROUNDS" ]]; then
  echo "cannot continue review loop beyond max rounds: $NEXT_ROUND > $MAX_ROUNDS" >&2
  exit 1
fi

GIT_ROOT="$(git -C "$PROJECT_ROOT" rev-parse --show-toplevel)"
COMMIT_MESSAGE="chore(opsx): review checkpoint $CHANGE_ID round $NEXT_ROUND"

git -C "$GIT_ROOT" add -A -- . ':(exclude)openspec/changes/*/workflow-state/*'

if git -C "$GIT_ROOT" diff --cached --quiet; then
  git -C "$GIT_ROOT" commit --allow-empty -m "$COMMIT_MESSAGE" >/dev/null
else
  git -C "$GIT_ROOT" commit -m "$COMMIT_MESSAGE" >/dev/null
fi

NEW_HEAD_SHA="$(git -C "$GIT_ROOT" rev-parse HEAD)"
REQUESTED_AT="$(timestamp)"
NEXT_ACTION="request-code-review-round-$NEXT_ROUND"

"$UPDATE_SCRIPT" "$CHANGE_ID" workflow current_phase "code-review" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "$NEXT_ACTION" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_requested_at "$REQUESTED_AT" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_completed_at "UNSET" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_feedback "UNSET" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_round "$NEXT_ROUND" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_loop_status "pending_review" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_base_sha "$PREV_HEAD_SHA" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_head_sha "$NEW_HEAD_SHA" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "auto_phase_55_started:round=$NEXT_ROUND" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" task review_status "PENDING_REVIEW" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" task next_action "$NEXT_ACTION" "$PROJECT_ROOT"

"$APPEND_AUDIT_SCRIPT" \
  "$CHANGE_ID" \
  "code-review" \
  "${MODE:-UNSET}" \
  "${TOOL:-UNSET}" \
  "continue automatic code review loop round $NEXT_ROUND" \
  "PENDING_REVIEW" \
  "$NEXT_ACTION" \
  "$PROJECT_ROOT"

echo "review_loop_continued: $CHANGE_ID"
echo "review_round: $NEXT_ROUND"
echo "review_base_sha: $PREV_HEAD_SHA"
echo "review_head_sha: $NEW_HEAD_SHA"
