#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <change-id> [project-root]" >&2
  exit 1
fi

CHANGE_ID="$1"
PROJECT_ROOT="${2:-$PWD}"
CHECKLIST_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/review-checklist.md"

if [[ ! -f "$CHECKLIST_FILE" ]]; then
  echo "Review checklist missing: $CHECKLIST_FILE" >&2
 exit 1
fi

echo "Please confirm at least the following before review:"
sed -n '1,120p' "$CHECKLIST_FILE"
