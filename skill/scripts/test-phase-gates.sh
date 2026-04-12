#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1" >&2; exit 1; }

bash "$SCRIPT_DIR/init-change-state.sh" "TEST-GATE" "$TEST_DIR" >/dev/null

bash "$SCRIPT_DIR/prepare-phase-gate.sh" "TEST-GATE" "archive" "run openspec-archive-change" "$TEST_DIR" >/dev/null
STATE_FILE="$TEST_DIR/openspec/changes/TEST-GATE/workflow-state/current-workflow-state.md"

grep -q 'archive-approval' "$STATE_FILE" || fail "prepare-phase-gate 未进入 archive-approval"
grep -q 'await-user-approval' "$STATE_FILE" || fail "prepare-phase-gate 未写入等待审批动作"
pass "prepare-phase-gate 写入审批前状态"

bash "$SCRIPT_DIR/enter-approved-phase.sh" "TEST-GATE" "archive" "run openspec-archive-change" "$TEST_DIR" >/dev/null

grep -q '^.*`current_phase`: `archive`$' "$STATE_FILE" || fail "enter-approved-phase 未进入 archive"
grep -q '^.*`checkpoint_status`: `approved`$' "$STATE_FILE" || fail "enter-approved-phase 未记录 approved"
grep -q 'run openspec-archive-change' "$STATE_FILE" || fail "enter-approved-phase 未写入执行动作"
pass "enter-approved-phase 进入已批准阶段"
