#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <opencode> <prompt-file> [change-id] [mode] [project-root]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL="$1"
PROMPT_FILE="$2"
CHANGE_ID="${3:-}"
MODE="${4:-}"
PROJECT_ROOT="${5:-$PWD}"

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Prompt file missing: $PROMPT_FILE" >&2
  exit 1
fi

if [[ -n "$CHANGE_ID" && -n "$MODE" ]]; then
  "$ROOT_DIR/scripts/validate-execution-state.sh" "$CHANGE_ID" "$MODE" "$PROJECT_ROOT"
fi

case "$TOOL" in
  opencode)
    echo "Executing: opencode run < $PROMPT_FILE"
    opencode run "$(cat "$PROMPT_FILE")"
    ;;
  claude-code)
    echo "claude-code is documented as a placeholder, but no runnable wrapper exists in this environment." >&2
    exit 2
    ;;
  *)
    echo "Unsupported tool: $TOOL" >&2
    exit 1
    ;;
esac
