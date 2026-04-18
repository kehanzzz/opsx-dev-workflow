#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1" >&2; exit 1; }

repo="$TEST_DIR/render-repo"
mkdir -p "$repo/openspec/changes/CHANGE-999/workflow-state"
git init "$repo" >/dev/null 2>&1
git -C "$repo" config user.name "OpsX Test"
git -C "$repo" config user.email "opsx-test@example.com"
printf "seed\n" > "$repo/README.md"
git -C "$repo" add README.md
git -C "$repo" commit -m "chore: seed" >/dev/null 2>&1
git -C "$repo" checkout -b feature/finalization >/dev/null 2>&1
printf "# state\n" > "$repo/openspec/changes/CHANGE-999/workflow-state/current-workflow-state.md"
printf "# audit\n" > "$repo/openspec/changes/CHANGE-999/workflow-state/audit-log.md"
printf "# plan\n" > "$repo/openspec/changes/CHANGE-999/workflow-state/current-plan.md"

archive_prompt="$TEST_DIR/archive-prompt.md"
branch_prompt="$TEST_DIR/branch-finish-prompt.md"

bash "$SCRIPT_DIR/render-archive-prompt.sh" "CHANGE-999" "$repo" "$archive_prompt" >/dev/null
bash "$SCRIPT_DIR/render-branch-finish-prompt.sh" "CHANGE-999" "$repo" "$branch_prompt" >/dev/null

grep -qF "$repo/openspec/changes/CHANGE-999/workflow-state" "$archive_prompt" || fail "archive prompt 未注入 workflow-state 路径"
grep -qF "openspec archive-change \"CHANGE-999\"" "$archive_prompt" || fail "archive prompt 未注入归档命令"
grep -qF "STATUS: COMPLETED|BLOCKED" "$archive_prompt" || fail "archive prompt 未保留输出契约"
pass "archive prompt 渲染正确"

grep -qF "$repo/openspec/changes/CHANGE-999/workflow-state" "$branch_prompt" || fail "branch-finish prompt 未注入 workflow-state 路径"
grep -qF "superpowers:finishing-a-development-branch" "$branch_prompt" || fail "branch-finish prompt 未注入目标技能"
grep -qF "STATUS: COMPLETED|BLOCKED" "$branch_prompt" || fail "branch-finish prompt 未保留输出契约"
pass "branch-finish prompt 渲染正确"
