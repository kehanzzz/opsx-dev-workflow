#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1" >&2; exit 1; }

bash "$SCRIPT_DIR/init-change-state.sh" "TEST-CHECK-STATE" "$TEST_DIR" >/dev/null

STATE_FILE="$TEST_DIR/openspec/changes/TEST-CHECK-STATE/workflow-state/current-workflow-state.md"

perl -0pi -e 's/- `review_round`: `UNSET`\n//g; s/- `review_max_rounds`: `UNSET`\n//g; s/- `review_loop_status`: `UNSET`\n//g; s/- `review_base_sha`: `UNSET`\n//g; s/- `review_head_sha`: `UNSET`\n//g; s/- `finalization_stage`: `UNSET`\n//g; s/- `memory_generation_status`: `UNSET`\n//g; s/- `archive_status`: `UNSET`\n//g; s/- `branch_finish_status`: `UNSET`\n//g' "$STATE_FILE"

output="$(bash "$SCRIPT_DIR/check-workflow-state.sh" "TEST-CHECK-STATE" "$TEST_DIR" 2>&1 || true)"

echo "$output" | grep -q 'Warning: State file missing optional field: review_round' || fail "未提示缺少 review_round"
echo "$output" | grep -q 'Warning: State file missing optional field: review_loop_status' || fail "未提示缺少 review_loop_status"
echo "$output" | grep -q 'Warning: State file missing optional field: finalization_stage' || fail "未提示缺少 finalization_stage"
echo "$output" | grep -q 'Warning: State file missing optional field: memory_generation_status' || fail "未提示缺少 memory_generation_status"
echo "$output" | grep -q 'workflow-state: OK' || fail "缺少 review loop 字段时不应导致 check-workflow-state 失败"

pass "check-workflow-state 对 review loop 和 finalization 字段给出兼容性提示"
