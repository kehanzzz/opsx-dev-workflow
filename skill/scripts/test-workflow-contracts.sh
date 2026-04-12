#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT_TARGETS=(
  "$ROOT_DIR/SKILL.md"
  "$ROOT_DIR/references"
  "$ROOT_DIR/assets"
  "$ROOT_DIR/scripts/run-external-tool.sh"
)

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

pass() {
  echo "[PASS] $1"
}

assert_not_found() {
  local pattern="$1"
  shift
  local message="${@: -1}"
  local targets=("${@:1:$#-1}")

  if rg -n --fixed-strings "$pattern" "${targets[@]}" >/dev/null 2>&1; then
    fail "$message"
  fi

  pass "$message"
}

assert_found() {
  local pattern="$1"
  local target="$2"
  local message="$3"

  if ! rg -n --fixed-strings "$pattern" "$target" >/dev/null 2>&1; then
    fail "$message"
  fi

  pass "$message"
}

main() {
  assert_not_found "quality-priority" "${CONTRACT_TARGETS[@]}" "不再保留 quality-priority 旧命名"
  assert_not_found "efficiency-priority" "${CONTRACT_TARGETS[@]}" "不再保留 efficiency-priority 旧命名"

  assert_found 'Set `execution_mode` based on selection: `subagent-driven-development`, `quality-first`, or `efficiency-first`' \
    "$ROOT_DIR/SKILL.md" \
    "主工作流文档使用统一的 execution_mode 枚举"
  assert_found './scripts/update-state-field.sh <change_id> workflow <field> <value>' \
    "$ROOT_DIR/SKILL.md" \
    "主工作流文档展示 update-state-field.sh 正确签名"
  assert_found 'Phase 1 does not create a change yet, so do not call change-bound checkpoint scripts here.' \
    "$ROOT_DIR/SKILL.md" \
    "探索阶段明确不要求 change-bound checkpoint"

  assert_found 'Explicitly supported today:' \
    "$ROOT_DIR/references/external-agent-tools.md" \
    "外部工具文档明确当前已实现支持集"
  assert_found '`claude-code` remains a documented placeholder until a runnable wrapper exists.' \
    "$ROOT_DIR/references/external-agent-tools.md" \
    "外部工具文档将 claude-code 降级为占位能力"

  assert_found 'Optional: project memory generation if the project has explicitly enabled it.' \
    "$ROOT_DIR/SKILL.md" \
    "memory generation 已降级为显式启用的可选动作"
  assert_found './scripts/prepare-phase-gate.sh <change_id> archive "run openspec-archive-change"' \
    "$ROOT_DIR/SKILL.md" \
    "archive 改为执行前审批 gate"
  assert_found './scripts/enter-approved-phase.sh <change_id> branch-finish "run superpowers:finishing-a-development-branch"' \
    "$ROOT_DIR/SKILL.md" \
    "branch-finish 改为审批后进入执行阶段"
  assert_found 'Resolve the verification path first with `scripts/select-verification-strategy.sh`' \
    "$ROOT_DIR/references/workflow-reference.md" \
    "验证阶段文档提供 capability gating 和回退路径"
}

main "$@"
