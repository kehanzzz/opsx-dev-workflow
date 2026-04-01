#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 7 ]]; then
  echo "Usage: $0 <change-id> <phase> <mode> <tool> <action> <result> <next-action> [project-root]" >&2
  exit 1
fi

CHANGE_ID="$1"
PHASE="$2"
MODE="$3"
TOOL="$4"
ACTION="$5"
RESULT="$6"
NEXT_ACTION="$7"
PROJECT_ROOT="${8:-$PWD}"
AUDIT_FILE="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state/audit-log.md"

if [[ ! -f "$AUDIT_FILE" ]]; then
  echo "Audit log missing: $AUDIT_FILE" >&2
  exit 1
fi

TIMESTAMP="$(date '+%Y-%m-%dT%H:%M:%S%z')"

cat <<EOF >> "$AUDIT_FILE"

timestamp: $TIMESTAMP
phase: $PHASE
mode: $MODE
tool: $TOOL
action: $ACTION
result: $RESULT
next_action: $NEXT_ACTION
EOF

echo "appended: $AUDIT_FILE"
echo "timestamp: $TIMESTAMP"
