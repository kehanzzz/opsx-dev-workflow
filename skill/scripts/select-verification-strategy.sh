#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <backend-only|frontend-ui|full-stack> [capabilities_csv]" >&2
  exit 1
fi

SCOPE="$1"
CAPABILITIES_RAW="${2:-}"

normalize() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr '_' '-'
}

has_capability() {
  local needle
  needle="$(normalize "$1")"
  IFS=',' read -ra parts <<< "$CAPABILITIES_RAW"
  for part in "${parts[@]}"; do
    if [[ "$(normalize "$part")" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

PRIMARY="repository-verification"
SECONDARY="openspec-verify-change"
FALLBACK="run repository tests directly"

case "$SCOPE" in
  backend-only)
    if has_capability "api-tester"; then
      PRIMARY="API Tester"
    fi
    if has_capability "reality-checker"; then
      SECONDARY="Reality Checker"
    fi
    FALLBACK="run API and integration tests directly, then invoke openspec-verify-change"
    ;;
  frontend-ui)
    if has_capability "evidence-collector"; then
      PRIMARY="Evidence Collector"
    fi
    if has_capability "reality-checker"; then
      SECONDARY="Reality Checker"
    fi
    FALLBACK="run E2E/manual UI checks directly, capture screenshots if possible, then invoke openspec-verify-change"
    ;;
  full-stack)
    if has_capability "api-tester" && has_capability "evidence-collector"; then
      PRIMARY="API Tester + Evidence Collector"
    elif has_capability "api-tester"; then
      PRIMARY="API Tester"
    elif has_capability "evidence-collector"; then
      PRIMARY="Evidence Collector"
    fi
    if has_capability "reality-checker"; then
      SECONDARY="Reality Checker"
    fi
    FALLBACK="run API integration plus E2E/manual checks directly, then invoke openspec-verify-change"
    ;;
  *)
    echo "Unsupported scope: $SCOPE" >&2
    exit 1
    ;;
esac

echo "verification_scope: $SCOPE"
echo "primary: $PRIMARY"
echo "secondary: $SECONDARY"
echo "fallback: $FALLBACK"
