#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1" >&2; exit 1; }

full_output="$(bash "$SCRIPT_DIR/select-verification-strategy.sh" "full-stack" "api-tester,evidence-collector,reality-checker")"
echo "$full_output" | grep -q 'primary: API Tester + Evidence Collector' || fail "full-stack 未选择双主验证能力"
echo "$full_output" | grep -q 'secondary: Reality Checker' || fail "full-stack 未选择 Reality Checker"
pass "full-stack 能力齐全时选择完整验证链路"

fallback_output="$(bash "$SCRIPT_DIR/select-verification-strategy.sh" "frontend-ui")"
echo "$fallback_output" | grep -q 'primary: repository-verification' || fail "缺少能力时未回退到仓库验证"
echo "$fallback_output" | grep -q 'openspec-verify-change' || fail "缺少能力时未给出 openspec 回退路径"
pass "缺少能力时回退到仓库级验证"
