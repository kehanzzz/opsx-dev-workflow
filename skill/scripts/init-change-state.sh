#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/assets/state-templates"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <change-id> [project-root]" >&2
  exit 1
fi

CHANGE_ID="$1"
PROJECT_ROOT="${2:-$PWD}"
TARGET_DIR="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state"

mkdir -p "$TARGET_DIR"

for file in current-workflow-state.md current-plan.md current-task.md review-checklist.md audit-log.md; do
  cp -n "$TEMPLATE_DIR/$file" "$TARGET_DIR/$file"
done

echo "workflow_state_dir: $TARGET_DIR"
