#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <change-id> [max-rounds] [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGE_ID="$1"
MAX_ROUNDS="${2:-2}"
PROJECT_ROOT="${3:-$PWD}"
STATE_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/current-workflow-state.md"
TASK_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/current-task.md"

UPDATE_SCRIPT="$ROOT_DIR/scripts/update-state-field.sh"
APPEND_AUDIT_SCRIPT="$ROOT_DIR/scripts/append-audit-log.sh"

if [[ ! -f "$STATE_FILE" || ! -f "$TASK_FILE" ]]; then
  echo "Missing workflow-state files for change: $CHANGE_ID" >&2
  exit 1
fi

if ! [[ "$MAX_ROUNDS" =~ ^[0-9]+$ ]] || [[ "$MAX_ROUNDS" -lt 1 ]]; then
  echo "max-rounds must be a positive integer: $MAX_ROUNDS" >&2
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

GIT_ROOT="$(git -C "$PROJECT_ROOT" rev-parse --show-toplevel)"
BASE_SHA="$(git -C "$GIT_ROOT" rev-parse HEAD)"
COMMIT_MESSAGE="chore(opsx): review checkpoint $CHANGE_ID round 1"

git -C "$GIT_ROOT" add -A -- . ':(exclude)openspec/changes/*/workflow-state/*'

if git -C "$GIT_ROOT" diff --cached --quiet; then
  git -C "$GIT_ROOT" commit --allow-empty -m "$COMMIT_MESSAGE" >/dev/null
else
  git -C "$GIT_ROOT" commit -m "$COMMIT_MESSAGE" >/dev/null
fi

HEAD_SHA="$(git -C "$GIT_ROOT" rev-parse HEAD)"
MODE="$(get_field "$STATE_FILE" execution_mode)"
TOOL="$(get_field "$STATE_FILE" external_tool)"
REQUESTED_AT="$(timestamp)"

"$UPDATE_SCRIPT" "$CHANGE_ID" workflow current_phase "code-review" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow next_action "request-code-review-round-1" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_requested_at "$REQUESTED_AT" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_completed_at "UNSET" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_feedback "UNSET" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_round "1" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_max_rounds "$MAX_ROUNDS" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_loop_status "pending_review" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_base_sha "$BASE_SHA" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow review_head_sha "$HEAD_SHA" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" workflow notes "auto_phase_55_started:round=1" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" task review_status "PENDING_REVIEW" "$PROJECT_ROOT"
"$UPDATE_SCRIPT" "$CHANGE_ID" task next_action "request-code-review-round-1" "$PROJECT_ROOT"

"$APPEND_AUDIT_SCRIPT" \
  "$CHANGE_ID" \
  "code-review" \
  "${MODE:-UNSET}" \
  "${TOOL:-UNSET}" \
  "start automatic code review loop round 1" \
  "PENDING_REVIEW" \
  "request-code-review-round-1" \
  "$PROJECT_ROOT"

echo "review_loop_started: $CHANGE_ID"
echo "review_round: 1"
echo "review_base_sha: $BASE_SHA"
echo "review_head_sha: $HEAD_SHA"
