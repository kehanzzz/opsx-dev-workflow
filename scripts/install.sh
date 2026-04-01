#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-}"
MODE="${2:-link}"

if [[ -z "$HOST" ]]; then
  echo "usage: $0 <host> [link|copy]" >&2
  exit 1
fi

"$(dirname "$0")/check-prerequisites.sh"

case "$HOST" in
  codex|claude-code|gemini-cli|opencode)
    ;;
  *)
    echo "unsupported host: $HOST" >&2
    exit 1
    ;;
esac

case "$MODE" in
  link|copy)
    ;;
  *)
    echo "unsupported mode: $MODE" >&2
    exit 1
    ;;
esac

echo "host: $HOST"
echo "mode: $MODE"
echo "upstream dependencies:"
echo "- superpowers: https://github.com/obra/superpowers"
echo "- OpenSpec: https://github.com/Fission-AI/OpenSpec"
echo "next: follow docs/installation/$HOST.md"
