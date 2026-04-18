#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1" >&2; exit 1; }

bash "$SCRIPT_DIR/init-change-state.sh" "TEST-GATE" "$TEST_DIR" >/dev/null

bash "$SCRIPT_DIR/prepare-phase-gate.sh" "TEST-GATE" "finalization" "run finalization pipeline" "$TEST_DIR" >/dev/null
STATE_FILE="$TEST_DIR/openspec/changes/TEST-GATE/workflow-state/current-workflow-state.md"

grep -q 'finalization-approval' "$STATE_FILE" || fail "prepare-phase-gate 未进入 finalization-approval"
grep -q 'await-user-approval' "$STATE_FILE" || fail "prepare-phase-gate 未写入等待审批动作"
grep -q 'pending_gate:finalization' "$STATE_FILE" || fail "prepare-phase-gate 未记录 finalization gate"
pass "prepare-phase-gate 写入 finalization 审批前状态"

bash "$SCRIPT_DIR/enter-approved-phase.sh" "TEST-GATE" "finalization" "run finalization pipeline" "$TEST_DIR" >/dev/null

grep -q '^.*`current_phase`: `finalization`$' "$STATE_FILE" || fail "enter-approved-phase 未进入 finalization"
grep -q '^.*`checkpoint_status`: `approved`$' "$STATE_FILE" || fail "enter-approved-phase 未记录 approved"
grep -q 'run finalization pipeline' "$STATE_FILE" || fail "enter-approved-phase 未写入执行动作"
pass "enter-approved-phase 进入已批准的 finalization 阶段"
