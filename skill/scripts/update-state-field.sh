#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <change-id> <workflow|plan|task> <field> <value> [project-root]" >&2
  exit 1
fi

CHANGE_ID="$1"
STATE_KIND="$2"
FIELD_NAME="$3"
FIELD_VALUE="$4"
PROJECT_ROOT="${5:-$PWD}"
STATE_DIR="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state"

case "$STATE_KIND" in
  workflow)
    TARGET_FILE="$STATE_DIR/current-workflow-state.md"
    ;;
  plan)
    TARGET_FILE="$STATE_DIR/current-plan.md"
    ;;
  task)
    TARGET_FILE="$STATE_DIR/current-task.md"
    ;;
  *)
    echo "Unsupported state kind: $STATE_KIND" >&2
    exit 1
    ;;
esac

if [[ ! -f "$TARGET_FILE" ]]; then
    echo "State file missing: $TARGET_FILE" >&2
  exit 1
fi

python3 - "$TARGET_FILE" "$FIELD_NAME" "$FIELD_VALUE" <<'PY'
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
field = sys.argv[2]
value = sys.argv[3]

text = target.read_text()
pattern = re.compile(rf"^(\- `{re.escape(field)}`: ).*$", re.MULTILINE)

if pattern.search(text):
    text = pattern.sub(rf"\1`{value}`", text, count=1)
else:
    if not text.endswith("\n"):
        text += "\n"
    text += f"- `{field}`: `{value}`\n"

target.write_text(text)
PY

echo "updated: $TARGET_FILE"
echo "field: $FIELD_NAME"
echo "value: $FIELD_VALUE"
