#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-}"
LABEL_FILE="${2:-.github/labels.tsv}"

if [[ -z "$REPO" ]]; then
  echo "usage: $0 <owner/repo> [label-file]" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "missing dependency: gh" >&2
  exit 1
fi

if [[ ! -f "$LABEL_FILE" ]]; then
  echo "label file not found: $LABEL_FILE" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated; run 'gh auth login' first" >&2
  exit 1
fi

while IFS=$'\t' read -r name color description; do
  if [[ -z "$name" || "$name" == \#* ]]; then
    continue
  fi

  gh label create "$name" \
    --repo "$REPO" \
    --color "$color" \
    --description "$description" \
    --force

  echo "synced label: $name"
done < "$LABEL_FILE"

echo "labels: OK"
