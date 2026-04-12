#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_STATE_SCRIPT="$SCRIPT_DIR/update-state-field.sh"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <change_id> <status> [feedback] [summary_file_or_text]" >&2
  echo "  status: pending, approved, rejected" >&2
  echo "  feedback: optional user feedback text" >&2
  echo "  summary_file_or_text: optional summary file path or summary text" >&2
  exit 1
fi

CHANGE_ID="$1"
STATUS="$2"
FEEDBACK="${3:-}"
SUMMARY_INPUT="${4:-}"

case "$STATUS" in
  pending|approved|rejected)
    ;;
  *)
    echo "Invalid status: $STATUS" >&2
    echo "Valid values: pending, approved, rejected" >&2
    exit 1
    ;;
esac

PROJECT_ROOT="$PWD"
while [[ "$PROJECT_ROOT" != "/" ]]; do
  if [[ -d "$PROJECT_ROOT/openspec" ]]; then
    break
  fi
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

if [[ ! -d "$PROJECT_ROOT/openspec" ]]; then
  echo "Error: Could not find openspec directory" >&2
  exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STATE_DIR="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state"
SUMMARY_FILE="$STATE_DIR/checkpoint-summary.md"
SUMMARY_CONTENT=""

"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow "checkpoint_status" "$STATUS" "$PROJECT_ROOT"
"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow "checkpoint_updated_at" "$TIMESTAMP" "$PROJECT_ROOT"

if [[ -n "$SUMMARY_INPUT" ]]; then
  if [[ -f "$SUMMARY_INPUT" ]]; then
    SUMMARY_CONTENT="$(cat "$SUMMARY_INPUT")"
  else
    SUMMARY_CONTENT="$SUMMARY_INPUT"
  fi
elif [[ ! -t 0 ]]; then
  SUMMARY_CONTENT="$(cat)"
fi

if [[ -n "$SUMMARY_CONTENT" ]]; then
  printf '%s\n' "$SUMMARY_CONTENT" > "$SUMMARY_FILE"
  "$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow "checkpoint_summary" "checkpoint-summary.md" "$PROJECT_ROOT"
fi

if [[ -n "$FEEDBACK" ]]; then
  "$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow "checkpoint_feedback" "$FEEDBACK" "$PROJECT_ROOT"
fi

echo "Checkpoint status updated successfully"
echo "  change_id: $CHANGE_ID"
echo "  status: $STATUS"
echo "  timestamp: $TIMESTAMP"
if [[ -n "$FEEDBACK" ]]; then
  echo "  feedback: $FEEDBACK"
fi
if [[ -n "$SUMMARY_CONTENT" ]]; then
  echo "  summary_file: $SUMMARY_FILE"
fi
