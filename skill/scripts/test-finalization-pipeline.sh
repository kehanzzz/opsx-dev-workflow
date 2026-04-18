#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1" >&2; exit 1; }

get_field() {
  local file="$1"
  local field="$2"
  sed -n "s/^- \`${field}\`: \`\\(.*\\)\`$/\\1/p" "$file" | head -n 1
}

bash "$SCRIPT_DIR/init-change-state.sh" "TEST-FINAL" "$TEST_DIR" >/dev/null
STATE_FILE="$TEST_DIR/openspec/changes/TEST-FINAL/workflow-state/current-workflow-state.md"

bash "$SCRIPT_DIR/update-state-field.sh" "TEST-FINAL" workflow current_phase "finalization" "$TEST_DIR" >/dev/null
bash "$SCRIPT_DIR/start-finalization-pipeline.sh" "TEST-FINAL" "$TEST_DIR" >/dev/null

[[ "$(get_field "$STATE_FILE" finalization_stage)" == "memory-generation" ]] || fail "start-finalization-pipeline 未进入 memory-generation"
[[ "$(get_field "$STATE_FILE" memory_generation_status)" == "in_progress" ]] || fail "memory generation 未标记 in_progress"
[[ "$(get_field "$STATE_FILE" next_action)" == "dispatch-memory-generation-subagent" ]] || fail "未要求派发 memory generation subagent"
pass "finalization pipeline 从 memory generation 开始"

bash "$SCRIPT_DIR/complete-finalization-stage.sh" "TEST-FINAL" "memory-generation" "completed" "$TEST_DIR" >/dev/null
[[ "$(get_field "$STATE_FILE" finalization_stage)" == "archive" ]] || fail "memory generation 完成后未进入 archive"
[[ "$(get_field "$STATE_FILE" archive_status)" == "in_progress" ]] || fail "archive 未标记 in_progress"
[[ "$(get_field "$STATE_FILE" next_action)" == "dispatch-archive-subagent" ]] || fail "未要求派发 archive subagent"
pass "memory generation 完成后进入 archive"

bash "$SCRIPT_DIR/complete-finalization-stage.sh" "TEST-FINAL" "archive" "completed" "$TEST_DIR" >/dev/null
[[ "$(get_field "$STATE_FILE" finalization_stage)" == "branch-finish" ]] || fail "archive 完成后未进入 branch-finish"
[[ "$(get_field "$STATE_FILE" branch_finish_status)" == "in_progress" ]] || fail "branch-finish 未标记 in_progress"
[[ "$(get_field "$STATE_FILE" next_action)" == "dispatch-branch-finish-subagent" ]] || fail "未要求派发 branch-finish subagent"
pass "archive 完成后进入 branch-finish"

bash "$SCRIPT_DIR/complete-finalization-stage.sh" "TEST-FINAL" "branch-finish" "completed" "$TEST_DIR" >/dev/null
[[ "$(get_field "$STATE_FILE" finalization_stage)" == "done" ]] || fail "branch-finish 完成后未结束 finalization"
[[ "$(get_field "$STATE_FILE" next_action)" == "workflow-complete" ]] || fail "finalization 完成后 next_action 不正确"
pass "branch-finish 完成后结束 finalization"

bash "$SCRIPT_DIR/update-state-field.sh" "TEST-FINAL" workflow current_phase "finalization" "$TEST_DIR" >/dev/null
bash "$SCRIPT_DIR/start-finalization-pipeline.sh" "TEST-FINAL" "$TEST_DIR" >/dev/null
bash "$SCRIPT_DIR/complete-finalization-stage.sh" "TEST-FINAL" "memory-generation" "blocked" "$TEST_DIR" >/dev/null
[[ "$(get_field "$STATE_FILE" next_action)" == "await-user-finalization-resolution" ]] || fail "blocked 时未等待人工介入"
pass "finalization 任一子步骤 blocked 时停止流水线"
