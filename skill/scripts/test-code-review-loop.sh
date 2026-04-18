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

setup_git_repo() {
  git -C "$TEST_DIR" init >/dev/null 2>&1
  git -C "$TEST_DIR" config user.name "OpsX Test"
  git -C "$TEST_DIR" config user.email "opsx-test@example.com"
  echo "base" > "$TEST_DIR/work.txt"
  git -C "$TEST_DIR" add work.txt
  git -C "$TEST_DIR" commit -m "chore: base" >/dev/null 2>&1
  echo "feature" >> "$TEST_DIR/work.txt"
}

STATE_FILE=""
TASK_FILE=""

setup_change() {
  bash "$SCRIPT_DIR/init-change-state.sh" "TEST-REVIEW" "$TEST_DIR" >/dev/null
  STATE_FILE="$TEST_DIR/openspec/changes/TEST-REVIEW/workflow-state/current-workflow-state.md"
  TASK_FILE="$TEST_DIR/openspec/changes/TEST-REVIEW/workflow-state/current-task.md"
  bash "$SCRIPT_DIR/update-state-field.sh" "TEST-REVIEW" workflow current_phase "execute-plan" "$TEST_DIR" >/dev/null
  bash "$SCRIPT_DIR/update-state-field.sh" "TEST-REVIEW" workflow execution_mode "subagent-driven-development" "$TEST_DIR" >/dev/null
  bash "$SCRIPT_DIR/update-state-field.sh" "TEST-REVIEW" workflow external_tool "UNSET" "$TEST_DIR" >/dev/null
}

test_start_loop() {
  setup_git_repo
  setup_change

  bash "$SCRIPT_DIR/start-code-review-loop.sh" "TEST-REVIEW" 2 "$TEST_DIR" >/dev/null

  [[ "$(get_field "$STATE_FILE" current_phase)" == "code-review" ]] || fail "start-code-review-loop 未进入 code-review"
  [[ "$(get_field "$STATE_FILE" review_round)" == "1" ]] || fail "start-code-review-loop 未设置 round=1"
  [[ "$(get_field "$STATE_FILE" review_max_rounds)" == "2" ]] || fail "start-code-review-loop 未设置 max_rounds=2"
  [[ "$(get_field "$STATE_FILE" review_loop_status)" == "pending_review" ]] || fail "start-code-review-loop 未设置 pending_review"
  [[ "$(get_field "$STATE_FILE" next_action)" == "request-code-review-round-1" ]] || fail "start-code-review-loop 未写入下一动作"

  local base_sha head_sha
  base_sha="$(get_field "$STATE_FILE" review_base_sha)"
  head_sha="$(get_field "$STATE_FILE" review_head_sha)"
  [[ -n "$base_sha" && "$base_sha" != "UNSET" ]] || fail "start-code-review-loop 未记录 review_base_sha"
  [[ -n "$head_sha" && "$head_sha" != "UNSET" ]] || fail "start-code-review-loop 未记录 review_head_sha"
  [[ "$base_sha" != "$head_sha" ]] || fail "start-code-review-loop 记录的 review SHA 不应相同"
  pass "start-code-review-loop 初始化 review loop"
}

test_first_round_changes_requested() {
  setup_git_repo
  setup_change
  bash "$SCRIPT_DIR/start-code-review-loop.sh" "TEST-REVIEW" 2 "$TEST_DIR" >/dev/null

  bash "$SCRIPT_DIR/handle-code-review-result.sh" "TEST-REVIEW" "CHANGES_REQUESTED" "补充错误处理" "$TEST_DIR" >/dev/null

  [[ "$(get_field "$STATE_FILE" review_loop_status)" == "repairing" ]] || fail "首轮 CHANGES_REQUESTED 未进入 repairing"
  [[ "$(get_field "$STATE_FILE" next_action)" == "auto-fix-review-feedback-round-1" ]] || fail "首轮 CHANGES_REQUESTED 未进入自动修复动作"
  [[ "$(get_field "$TASK_FILE" review_status)" == "CHANGES_REQUESTED" ]] || fail "首轮 CHANGES_REQUESTED 未写入 task review_status"
  pass "首轮 CHANGES_REQUESTED 进入自动修复"
}

test_continue_loop() {
  setup_git_repo
  setup_change
  bash "$SCRIPT_DIR/start-code-review-loop.sh" "TEST-REVIEW" 2 "$TEST_DIR" >/dev/null
  bash "$SCRIPT_DIR/handle-code-review-result.sh" "TEST-REVIEW" "CHANGES_REQUESTED" "补充错误处理" "$TEST_DIR" >/dev/null
  echo "fix" >> "$TEST_DIR/work.txt"

  local prev_head
  prev_head="$(get_field "$STATE_FILE" review_head_sha)"

  bash "$SCRIPT_DIR/continue-code-review-loop.sh" "TEST-REVIEW" "$TEST_DIR" >/dev/null

  [[ "$(get_field "$STATE_FILE" review_round)" == "2" ]] || fail "continue-code-review-loop 未递增到第 2 轮"
  [[ "$(get_field "$STATE_FILE" review_loop_status)" == "pending_review" ]] || fail "continue-code-review-loop 未回到 pending_review"
  [[ "$(get_field "$STATE_FILE" next_action)" == "request-code-review-round-2" ]] || fail "continue-code-review-loop 未写入第二轮动作"
  [[ "$(get_field "$STATE_FILE" review_base_sha)" == "$prev_head" ]] || fail "continue-code-review-loop 未将上一轮 head 作为新的 base"
  pass "continue-code-review-loop 进入第二轮 review"
}

test_approved_transitions_to_verification() {
  setup_git_repo
  setup_change
  bash "$SCRIPT_DIR/start-code-review-loop.sh" "TEST-REVIEW" 2 "$TEST_DIR" >/dev/null

  bash "$SCRIPT_DIR/handle-code-review-result.sh" "TEST-REVIEW" "APPROVED" "review 通过" "$TEST_DIR" >/dev/null

  [[ "$(get_field "$STATE_FILE" current_phase)" == "verification" ]] || fail "APPROVED 后未进入 verification"
  [[ "$(get_field "$STATE_FILE" next_action)" == "openspec-verify-change" ]] || fail "APPROVED 后未写入 openspec-verify-change"
  [[ "$(get_field "$STATE_FILE" review_loop_status)" == "approved" ]] || fail "APPROVED 后未写入 approved 状态"
  [[ "$(get_field "$TASK_FILE" review_status)" == "APPROVED" ]] || fail "APPROVED 后未写入 task review_status"
  pass "APPROVED 后自动进入 Phase 6"
}

test_second_round_changes_requested_stops() {
  setup_git_repo
  setup_change
  bash "$SCRIPT_DIR/start-code-review-loop.sh" "TEST-REVIEW" 2 "$TEST_DIR" >/dev/null
  bash "$SCRIPT_DIR/handle-code-review-result.sh" "TEST-REVIEW" "CHANGES_REQUESTED" "补充错误处理" "$TEST_DIR" >/dev/null
  echo "fix" >> "$TEST_DIR/work.txt"
  bash "$SCRIPT_DIR/continue-code-review-loop.sh" "TEST-REVIEW" "$TEST_DIR" >/dev/null

  bash "$SCRIPT_DIR/handle-code-review-result.sh" "TEST-REVIEW" "CHANGES_REQUESTED" "第二轮仍有问题" "$TEST_DIR" >/dev/null

  [[ "$(get_field "$STATE_FILE" current_phase)" == "code-review" ]] || fail "第二轮 CHANGES_REQUESTED 不应离开 code-review"
  [[ "$(get_field "$STATE_FILE" review_loop_status)" == "manual_intervention_required" ]] || fail "第二轮 CHANGES_REQUESTED 未转人工介入"
  [[ "$(get_field "$STATE_FILE" next_action)" == "await-user-review-resolution" ]] || fail "第二轮 CHANGES_REQUESTED 未等待人工介入"
  pass "第二轮 CHANGES_REQUESTED 停止自动循环"
}

test_blocked_stops() {
  setup_git_repo
  setup_change
  bash "$SCRIPT_DIR/start-code-review-loop.sh" "TEST-REVIEW" 2 "$TEST_DIR" >/dev/null

  bash "$SCRIPT_DIR/handle-code-review-result.sh" "TEST-REVIEW" "BLOCKED" "需要人工决策" "$TEST_DIR" >/dev/null

  [[ "$(get_field "$STATE_FILE" current_phase)" == "code-review" ]] || fail "BLOCKED 不应离开 code-review"
  [[ "$(get_field "$STATE_FILE" review_loop_status)" == "manual_intervention_required" ]] || fail "BLOCKED 未转人工介入"
  [[ "$(get_field "$STATE_FILE" next_action)" == "await-user-review-resolution" ]] || fail "BLOCKED 未等待人工介入"
  pass "BLOCKED 时停止自动循环"
}

main() {
  test_start_loop
  rm -rf "$TEST_DIR/.git" "$TEST_DIR/openspec" "$TEST_DIR/work.txt" 2>/dev/null || true
  test_first_round_changes_requested
  rm -rf "$TEST_DIR/.git" "$TEST_DIR/openspec" "$TEST_DIR/work.txt" 2>/dev/null || true
  test_continue_loop
  rm -rf "$TEST_DIR/.git" "$TEST_DIR/openspec" "$TEST_DIR/work.txt" 2>/dev/null || true
  test_approved_transitions_to_verification
  rm -rf "$TEST_DIR/.git" "$TEST_DIR/openspec" "$TEST_DIR/work.txt" 2>/dev/null || true
  test_second_round_changes_requested_stops
  rm -rf "$TEST_DIR/.git" "$TEST_DIR/openspec" "$TEST_DIR/work.txt" 2>/dev/null || true
  test_blocked_stops
}

main "$@"
