#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_STATE_SCRIPT="$SCRIPT_DIR/update-state-field.sh"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <change_id> <status> [feedback]" >&2
  echo "  status: pending, approved, rejected" >&2
  echo "  feedback: optional user feedback text" >&2
  exit 1
fi

CHANGE_ID="$1"
STATUS="$2"
FEEDBACK="${3:-}"

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

"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow "checkpoint_status" "$STATUS" "$PROJECT_ROOT"
"$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow "review_completed_at" "$TIMESTAMP" "$PROJECT_ROOT"

if [[ -n "$FEEDBACK" ]]; then
  "$UPDATE_STATE_SCRIPT" "$CHANGE_ID" workflow "review_feedback" "$FEEDBACK" "$PROJECT_ROOT"
fi

echo "Checkpoint status updated successfully"
echo "  change_id: $CHANGE_ID"
echo "  status: $STATUS"
echo "  timestamp: $TIMESTAMP"
if [[ -n "$FEEDBACK" ]]; then
  echo "  feedback: $FEEDBACK"
fi