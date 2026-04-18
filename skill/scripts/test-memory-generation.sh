#!/usr/bin/env bash

set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR=""

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_error() { echo -e "${RED}[FAIL]${NC} $1"; }

pass_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_success "$1"
}

fail_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_error "$1"
    [[ -n "${2:-}" ]] && log_error "  详情: $2"
}

cleanup() {
    [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]] && rm -rf "$TEST_DIR"
}
trap cleanup EXIT

line_no() {
    local pattern="$1"
    local file="$2"
    rg -n --fixed-strings -- "$pattern" "$file" | head -n 1 | cut -d: -f1 || true
}

echo ""
echo "========================================"
echo -e "  ${BLUE}记忆生成功能单元测试${NC}"
echo "========================================"
echo ""

log_info "创建临时测试环境..."
TEST_DIR=$(mktemp -d)
git init "$TEST_DIR" >/dev/null 2>&1
log_info "测试目录: $TEST_DIR"

echo ""
log_info "=== get-project-root.sh 测试 ==="

mkdir -p "$TEST_DIR/src/lib"
result=$("$SCRIPT_DIR/get-project-root.sh" "$TEST_DIR/src/lib" 2>&1)
[[ "$result" == "$TEST_DIR" ]] && pass_test "从子目录找到项目根目录" || fail_test "项目根目录不正确" "期望: $TEST_DIR, 实际: $result"

result=$("$SCRIPT_DIR/get-project-root.sh" "$TEST_DIR" 2>&1)
[[ "$result" == "$TEST_DIR" ]] && pass_test "从根目录返回正确" || fail_test "根目录返回不正确"

result=$("$SCRIPT_DIR/get-project-root.sh" "/tmp" 2>&1) && fail_test "非 Git 目录应返回错误" || pass_test "非 Git 目录正确报错"

worktree_root="$TEST_DIR/worktree-repo"
mkdir -p "$worktree_root/packages/app"
printf 'gitdir: /tmp/fake-worktree\n' > "$worktree_root/.git"
result=$("$SCRIPT_DIR/get-project-root.sh" "$worktree_root/packages/app" 2>&1)
[[ "$result" == "$worktree_root" ]] && pass_test "兼容 git worktree 的 .git 文件" || fail_test "worktree 根目录识别失败" "$result"

"$SCRIPT_DIR/get-project-root.sh" --help 2>&1 | grep -q "项目根目录" && pass_test "帮助信息正确" || fail_test "帮助信息不正确"

echo ""
log_info "=== ensure-docs-dir.sh 测试 ==="

rm -rf "$TEST_DIR/docs"
result=$("$SCRIPT_DIR/ensure-docs-dir.sh" "$TEST_DIR" 2>&1)
[[ -d "$result" ]] && pass_test "创建新 docs 目录" || fail_test "docs 目录未创建"

result=$("$SCRIPT_DIR/ensure-docs-dir.sh" "$TEST_DIR" 2>&1)
[[ "$result" == "$TEST_DIR/docs" ]] && pass_test "已存在 docs 目录返回正确" || fail_test "返回路径不正确"

result=$("$SCRIPT_DIR/ensure-docs-dir.sh" "/nonexistent/path" 2>&1) && fail_test "无效目录应返回错误" || pass_test "无效项目根目录正确报错"

"$SCRIPT_DIR/ensure-docs-dir.sh" --help 2>&1 | grep -q "docs" && pass_test "帮助信息正确" || fail_test "帮助信息不正确"

echo ""
log_info "=== merge-document.sh 测试 ==="

target="$TEST_DIR/new-doc.md"
"$SCRIPT_DIR/merge-document.sh" "$target" "测试内容" --mode=smart >/dev/null 2>&1
[[ -f "$target" ]] && grep -q "测试内容" "$target" && pass_test "创建新文档" || fail_test "文档内容不正确"

target="$TEST_DIR/append-test.md"
echo "原始内容" > "$target"
"$SCRIPT_DIR/merge-document.sh" "$target" "追加内容" --mode=append >/dev/null 2>&1
grep -q "原始内容" "$target" && grep -q "追加内容" "$target" && pass_test "追加模式正确" || fail_test "追加模式不正确"

target="$TEST_DIR/prepend-test.md"
echo "原始内容" > "$target"
"$SCRIPT_DIR/merge-document.sh" "$target" "前置内容" --mode=prepend >/dev/null 2>&1
first=$(head -n 1 "$target")
[[ "$first" == "前置内容" ]] && pass_test "前置模式正确" || fail_test "前置模式不正确"

target="$TEST_DIR/smart-structure.md"
cat > "$target" <<'EOF'
# 测试文档

## 概述
这是一个测试文档。

## 变更历史
### 2026-01-01
初始版本
EOF
"$SCRIPT_DIR/merge-document.sh" "$target" "添加了新功能" --mode=smart >/dev/null 2>&1
title_line=$(line_no "# 测试文档" "$target")
overview_line=$(line_no "## 概述" "$target")
changelog_line=$(line_no "## 变更历史" "$target")
new_line=$(line_no "添加了新功能" "$target")
old_line=$(line_no "### 2026-01-01" "$target")
if [[ -n "$title_line" && -n "$overview_line" && -n "$changelog_line" && -n "$new_line" && -n "$old_line" ]] \
    && (( title_line < overview_line )) \
    && (( overview_line < changelog_line )) \
    && (( changelog_line < new_line )) \
    && (( new_line < old_line )); then
    pass_test "smart 模式保留原有文档结构并将新记录插入变更历史顶部"
else
    fail_test "smart 模式破坏了文档结构" "$(cat "$target")"
fi

target="$TEST_DIR/smart-repeat.md"
echo "# 已有文档" > "$target"
"$SCRIPT_DIR/merge-document.sh" "$target" "第一次更新" --mode=smart >/dev/null 2>&1
"$SCRIPT_DIR/merge-document.sh" "$target" "第二次更新" --mode=smart >/dev/null 2>&1
changelog_count=$(rg -c "^## 变更历史$" "$target")
second_line=$(line_no "第二次更新" "$target")
first_line=$(line_no "第一次更新" "$target")
if [[ "$changelog_count" == "1" && -n "$second_line" && -n "$first_line" ]] && (( second_line < first_line )); then
    pass_test "重复 smart 合并不会重复创建变更历史标题"
else
    fail_test "重复 smart 合并结果不正确" "$(cat "$target")"
fi

target="$TEST_DIR/structured-learnings.md"
cat > "$target" <<'EOF'
# 项目经验与教训

## 高价值失败模式

### 旧模式
- 适用范围: 旧范围
- 触发信号: 旧信号

## 调试与诊断启发式

- 启发式 1: 先看旧日志

## 更新日志

### 2026-01-01 10:00:00
- Change ID: old-change
- Generated At: 2026-01-01T10:00:00Z
- What Changed in Canonical Understanding: 旧结论
EOF

cat > "$TEST_DIR/new-learnings-content.md" <<'EOF'
# 项目经验与教训

## 高价值失败模式

### 新模式
- 适用范围: review 交接
- 触发信号: 回归遗漏
- 常见误判: 只看实现不看证据

## 调试与诊断启发式

- 启发式 1: 先看测试再看实现
- 适用条件: 回归失败

## Review 与交接检查清单

- 检查项 1: 确认回归命令已运行
- 失败信号: 只说通过没有证据

## 更新日志

### 2026-04-12 12:00:00
- Change ID: new-change
- Generated At: 2026-04-12T12:00:00Z
- What Changed in Canonical Understanding: 新增 review 与交接教训
EOF

"$SCRIPT_DIR/merge-document.sh" "$target" - --mode=smart < "$TEST_DIR/new-learnings-content.md" >/dev/null 2>&1
new_mode_line=$(line_no "### 新模式" "$target")
old_mode_line=$(line_no "### 旧模式" "$target")
new_checklist_line=$(line_no "## Review 与交接检查清单" "$target")
new_change_line=$(line_no "Change ID: new-change" "$target")
old_change_line=$(line_no "Change ID: old-change" "$target")
if [[ -n "$new_mode_line" && -z "$old_mode_line" && -n "$new_checklist_line" && -n "$new_change_line" && -n "$old_change_line" ]] \
    && (( new_change_line < old_change_line )); then
    pass_test "smart 模式可按 section 合并 structured learnings 文档并保留日志顺序"
else
    fail_test "structured smart 合并结果不正确" "$(cat "$target")"
fi

target="$TEST_DIR/structured-business.md"
cat > "$target" <<'EOF'
# 业务介绍

## 业务目标与存在理由

- 产品/系统存在的根本原因: 旧目标

## 核心业务对象

### 订单
- 定义: 旧定义

## 更新日志

### 2026-01-01 09:00:00
- Change ID: old-business
- Generated At: 2026-01-01T09:00:00Z
- What Changed in Canonical Understanding: 旧业务结论
EOF

cat > "$TEST_DIR/new-business-content.md" <<'EOF'
# 业务介绍

## 核心业务对象

### 订单
- 定义: 新定义
- 与其他对象的关系: 与支付关联

## 更新日志

### 2026-04-12 12:10:00
- Change ID: new-business
- Generated At: 2026-04-12T12:10:00Z
- What Changed in Canonical Understanding: 修正订单定义
EOF

"$SCRIPT_DIR/merge-document.sh" "$target" - --mode=smart < "$TEST_DIR/new-business-content.md" >/dev/null 2>&1
new_business_line=$(line_no "- 定义: 新定义" "$target")
old_business_line=$(line_no "- 定义: 旧定义" "$target")
goal_line=$(line_no "- 产品/系统存在的根本原因: 旧目标" "$target")
new_business_change_line=$(line_no "Change ID: new-business" "$target")
old_business_change_line=$(line_no "Change ID: old-business" "$target")
if [[ -n "$new_business_line" && -z "$old_business_line" && -n "$goal_line" && -n "$new_business_change_line" && -n "$old_business_change_line" ]] \
    && (( new_business_change_line < old_business_change_line )); then
    pass_test "smart 模式只更新 business 的目标 section 并保留其他正文 section"
else
    fail_test "business structured merge 结果不正确" "$(cat "$target")"
fi

target="$TEST_DIR/structured-product.md"
cat > "$target" <<'EOF'
# 产品功能

## 目标用户与使用角色

### 审核员
- 核心目标: 旧目标

## 核心场景

### 审核工单
- 触发条件: 用户提交
- 用户路径: 旧路径

## 更新日志

### 2026-01-01 09:10:00
- Change ID: old-product
- Generated At: 2026-01-01T09:10:00Z
- What Changed in Canonical Understanding: 旧产品结论
EOF

cat > "$TEST_DIR/new-product-content.md" <<'EOF'
# 产品功能

## 核心场景

### 审核工单
- 触发条件: 用户提交
- 用户路径: 新路径
- 关键阻塞点: 信息不全

## 更新日志

### 2026-04-12 12:20:00
- Change ID: new-product
- Generated At: 2026-04-12T12:20:00Z
- What Changed in Canonical Understanding: 更新审核主路径
EOF

"$SCRIPT_DIR/merge-document.sh" "$target" - --mode=smart < "$TEST_DIR/new-product-content.md" >/dev/null 2>&1
new_product_path_line=$(line_no "- 用户路径: 新路径" "$target")
old_product_path_line=$(line_no "- 用户路径: 旧路径" "$target")
role_goal_line=$(line_no "- 核心目标: 旧目标" "$target")
new_product_change_line=$(line_no "Change ID: new-product" "$target")
old_product_change_line=$(line_no "Change ID: old-product" "$target")
if [[ -n "$new_product_path_line" && -z "$old_product_path_line" && -n "$role_goal_line" && -n "$new_product_change_line" && -n "$old_product_change_line" ]] \
    && (( new_product_change_line < old_product_change_line )); then
    pass_test "smart 模式只更新 product 的目标 section 并保留其他正文 section"
else
    fail_test "product structured merge 结果不正确" "$(cat "$target")"
fi

target="$TEST_DIR/structured-architecture.md"
cat > "$target" <<'EOF'
# 架构文档

## 系统目标与架构边界

- 系统目标: 旧系统目标

## 关键技术决策

### 旧决策
- 背景: 旧背景
- 决策: 旧决策

## 更新日志

### 2026-01-01 09:20:00
- Change ID: old-architecture
- Generated At: 2026-01-01T09:20:00Z
- What Changed in Canonical Understanding: 旧架构结论
EOF

cat > "$TEST_DIR/new-architecture-content.md" <<'EOF'
# 架构文档

## 关键技术决策

### 新决策
- 背景: 新背景
- 决策: 新决策
- 权衡: 更稳定

## 更新日志

### 2026-04-12 12:30:00
- Change ID: new-architecture
- Generated At: 2026-04-12T12:30:00Z
- What Changed in Canonical Understanding: 更新关键技术决策
EOF

"$SCRIPT_DIR/merge-document.sh" "$target" - --mode=smart < "$TEST_DIR/new-architecture-content.md" >/dev/null 2>&1
new_architecture_decision_line=$(line_no "### 新决策" "$target")
old_architecture_decision_line=$(line_no "### 旧决策" "$target")
system_goal_line=$(line_no "- 系统目标: 旧系统目标" "$target")
new_architecture_change_line=$(line_no "Change ID: new-architecture" "$target")
old_architecture_change_line=$(line_no "Change ID: old-architecture" "$target")
if [[ -n "$new_architecture_decision_line" && -z "$old_architecture_decision_line" && -n "$system_goal_line" && -n "$new_architecture_change_line" && -n "$old_architecture_change_line" ]] \
    && (( new_architecture_change_line < old_architecture_change_line )); then
    pass_test "smart 模式只更新 architecture 的目标 section 并保留其他正文 section"
else
    fail_test "architecture structured merge 结果不正确" "$(cat "$target")"
fi

target="$TEST_DIR/append-business-section.md"
cat > "$target" <<'EOF'
# 业务介绍

## 业务目标与存在理由

- 产品/系统存在的根本原因: 稳定交付

## 核心业务对象

### 任务
- 定义: 开发任务

## 更新日志

### 2026-01-01 09:30:00
- Change ID: old-business-append
- Generated At: 2026-01-01T09:30:00Z
- What Changed in Canonical Understanding: 初始业务结论
EOF

cat > "$TEST_DIR/new-business-section.md" <<'EOF'
# 业务介绍

## 已验证的业务判断

- 判断 1: 先锁定需求再进入实现
- 证据: 多次返工复盘

## 更新日志

### 2026-04-12 12:40:00
- Change ID: new-business-append
- Generated At: 2026-04-12T12:40:00Z
- What Changed in Canonical Understanding: 新增已验证业务判断
EOF

"$SCRIPT_DIR/merge-document.sh" "$target" - --mode=smart < "$TEST_DIR/new-business-section.md" >/dev/null 2>&1
business_core_line=$(line_no "## 核心业务对象" "$target")
business_new_section_line=$(line_no "## 已验证的业务判断" "$target")
business_log_line=$(line_no "## 更新日志" "$target")
business_new_change_line=$(line_no "Change ID: new-business-append" "$target")
business_old_change_line=$(line_no "Change ID: old-business-append" "$target")
if [[ -n "$business_core_line" && -n "$business_new_section_line" && -n "$business_log_line" && -n "$business_new_change_line" && -n "$business_old_change_line" ]] \
    && (( business_core_line < business_new_section_line )) \
    && (( business_new_section_line < business_log_line )) \
    && (( business_new_change_line < business_old_change_line )); then
    pass_test "smart 模式可为 business 补入缺失 section 且保持正文顺序"
else
    fail_test "business 缺失 section 合并结果不正确" "$(cat "$target")"
fi

target="$TEST_DIR/append-product-section.md"
cat > "$target" <<'EOF'
# 产品功能

## 目标用户与使用角色

### 开发者
- 核心目标: 快速推进任务

## 核心任务（JTBD）

- 任务 1: 完成一次变更

## 更新日志

### 2026-01-01 09:40:00
- Change ID: old-product-append
- Generated At: 2026-01-01T09:40:00Z
- What Changed in Canonical Understanding: 初始产品结论
EOF

cat > "$TEST_DIR/new-product-section.md" <<'EOF'
# 产品功能

## 已知用户坑点

- 坑点 1: 误以为 review 可跳过验证
- 根因: 流程心智不清晰

## 更新日志

### 2026-04-12 12:50:00
- Change ID: new-product-append
- Generated At: 2026-04-12T12:50:00Z
- What Changed in Canonical Understanding: 新增用户坑点
EOF

"$SCRIPT_DIR/merge-document.sh" "$target" - --mode=smart < "$TEST_DIR/new-product-section.md" >/dev/null 2>&1
product_task_line=$(line_no "## 核心任务（JTBD）" "$target")
product_new_section_line=$(line_no "## 已知用户坑点" "$target")
product_log_line=$(line_no "## 更新日志" "$target")
product_new_change_line=$(line_no "Change ID: new-product-append" "$target")
product_old_change_line=$(line_no "Change ID: old-product-append" "$target")
if [[ -n "$product_task_line" && -n "$product_new_section_line" && -n "$product_log_line" && -n "$product_new_change_line" && -n "$product_old_change_line" ]] \
    && (( product_task_line < product_new_section_line )) \
    && (( product_new_section_line < product_log_line )) \
    && (( product_new_change_line < product_old_change_line )); then
    pass_test "smart 模式可为 product 补入缺失 section 且保持正文顺序"
else
    fail_test "product 缺失 section 合并结果不正确" "$(cat "$target")"
fi

target="$TEST_DIR/append-architecture-section.md"
cat > "$target" <<'EOF'
# 架构文档

## 系统目标与架构边界

- 系统目标: 支撑结构化交付

## 核心组件与职责

### workflow
- 职责: 驱动阶段流转

## 更新日志

### 2026-01-01 09:50:00
- Change ID: old-architecture-append
- Generated At: 2026-01-01T09:50:00Z
- What Changed in Canonical Understanding: 初始架构结论
EOF

cat > "$TEST_DIR/new-architecture-section.md" <<'EOF'
# 架构文档

## 运行与操作约束

- 关键运行假设: 脚本在 bash 环境执行
- 观测点: 单元测试与集成测试输出

## 更新日志

### 2026-04-12 13:00:00
- Change ID: new-architecture-append
- Generated At: 2026-04-12T13:00:00Z
- What Changed in Canonical Understanding: 新增运行约束
EOF

"$SCRIPT_DIR/merge-document.sh" "$target" - --mode=smart < "$TEST_DIR/new-architecture-section.md" >/dev/null 2>&1
architecture_component_line=$(line_no "## 核心组件与职责" "$target")
architecture_new_section_line=$(line_no "## 运行与操作约束" "$target")
architecture_log_line=$(line_no "## 更新日志" "$target")
architecture_new_change_line=$(line_no "Change ID: new-architecture-append" "$target")
architecture_old_change_line=$(line_no "Change ID: old-architecture-append" "$target")
if [[ -n "$architecture_component_line" && -n "$architecture_new_section_line" && -n "$architecture_log_line" && -n "$architecture_new_change_line" && -n "$architecture_old_change_line" ]] \
    && (( architecture_component_line < architecture_new_section_line )) \
    && (( architecture_new_section_line < architecture_log_line )) \
    && (( architecture_new_change_line < architecture_old_change_line )); then
    pass_test "smart 模式可为 architecture 补入缺失 section 且保持正文顺序"
else
    fail_test "architecture 缺失 section 合并结果不正确" "$(cat "$target")"
fi

mkdir -p "$TEST_DIR/ordered-business"
target="$TEST_DIR/ordered-business/business.md"
cat > "$target" <<'EOF'
# 业务介绍

## 业务目标与存在理由

- 产品/系统存在的根本原因: 稳定交付

## 业务边界与非目标

- 本系统负责: 负责流程编排

## 更新日志

### 2026-01-01 10:10:00
- Change ID: ordered-business-old
- Generated At: 2026-01-01T10:10:00Z
- What Changed in Canonical Understanding: 初始顺序
EOF

cat > "$TEST_DIR/ordered-business/new-content.md" <<'EOF'
# 业务介绍

## 核心业务对象

### 任务
- 定义: 结构化交付任务

## 更新日志

### 2026-04-12 13:10:00
- Change ID: ordered-business-new
- Generated At: 2026-04-12T13:10:00Z
- What Changed in Canonical Understanding: 新增核心业务对象
EOF

"$SCRIPT_DIR/merge-document.sh" "$target" - --mode=smart < "$TEST_DIR/ordered-business/new-content.md" >/dev/null 2>&1
ordered_business_goal_line=$(line_no "## 业务目标与存在理由" "$target")
ordered_business_object_line=$(line_no "## 核心业务对象" "$target")
ordered_business_boundary_line=$(line_no "## 业务边界与非目标" "$target")
if [[ -n "$ordered_business_goal_line" && -n "$ordered_business_object_line" && -n "$ordered_business_boundary_line" ]] \
    && (( ordered_business_goal_line < ordered_business_object_line )) \
    && (( ordered_business_object_line < ordered_business_boundary_line )); then
    pass_test "smart 模式按 business 模板顺序插入新增 section"
else
    fail_test "business 新增 section 未按模板顺序插入" "$(cat "$target")"
fi

mkdir -p "$TEST_DIR/ordered-product"
target="$TEST_DIR/ordered-product/product.md"
cat > "$target" <<'EOF'
# 产品功能

## 目标用户与使用角色

### 开发者
- 核心目标: 快速推进任务

## 关键体验原则

- 原则 1: 快速反馈

## 更新日志

### 2026-01-01 10:20:00
- Change ID: ordered-product-old
- Generated At: 2026-01-01T10:20:00Z
- What Changed in Canonical Understanding: 初始顺序
EOF

cat > "$TEST_DIR/ordered-product/new-content.md" <<'EOF'
# 产品功能

## 核心场景

### 审核工单
- 用户路径: 从计划到验证

## 更新日志

### 2026-04-12 13:20:00
- Change ID: ordered-product-new
- Generated At: 2026-04-12T13:20:00Z
- What Changed in Canonical Understanding: 新增核心场景
EOF

"$SCRIPT_DIR/merge-document.sh" "$target" - --mode=smart < "$TEST_DIR/ordered-product/new-content.md" >/dev/null 2>&1
ordered_product_role_line=$(line_no "## 目标用户与使用角色" "$target")
ordered_product_scene_line=$(line_no "## 核心场景" "$target")
ordered_product_experience_line=$(line_no "## 关键体验原则" "$target")
if [[ -n "$ordered_product_role_line" && -n "$ordered_product_scene_line" && -n "$ordered_product_experience_line" ]] \
    && (( ordered_product_role_line < ordered_product_scene_line )) \
    && (( ordered_product_scene_line < ordered_product_experience_line )); then
    pass_test "smart 模式按 product 模板顺序插入新增 section"
else
    fail_test "product 新增 section 未按模板顺序插入" "$(cat "$target")"
fi

mkdir -p "$TEST_DIR/ordered-architecture"
target="$TEST_DIR/ordered-architecture/architecture.md"
cat > "$target" <<'EOF'
# 架构文档

## 系统目标与架构边界

- 系统目标: 稳定执行

## 运行与操作约束

- 关键运行假设: bash 环境

## 更新日志

### 2026-01-01 10:30:00
- Change ID: ordered-architecture-old
- Generated At: 2026-01-01T10:30:00Z
- What Changed in Canonical Understanding: 初始顺序
EOF

cat > "$TEST_DIR/ordered-architecture/new-content.md" <<'EOF'
# 架构文档

## 关键技术决策

### 统一 merge 策略
- 决策: 使用 smart merge

## 更新日志

### 2026-04-12 13:30:00
- Change ID: ordered-architecture-new
- Generated At: 2026-04-12T13:30:00Z
- What Changed in Canonical Understanding: 新增关键技术决策
EOF

"$SCRIPT_DIR/merge-document.sh" "$target" - --mode=smart < "$TEST_DIR/ordered-architecture/new-content.md" >/dev/null 2>&1
ordered_architecture_goal_line=$(line_no "## 系统目标与架构边界" "$target")
ordered_architecture_decision_line=$(line_no "## 关键技术决策" "$target")
ordered_architecture_ops_line=$(line_no "## 运行与操作约束" "$target")
if [[ -n "$ordered_architecture_goal_line" && -n "$ordered_architecture_decision_line" && -n "$ordered_architecture_ops_line" ]] \
    && (( ordered_architecture_goal_line < ordered_architecture_decision_line )) \
    && (( ordered_architecture_decision_line < ordered_architecture_ops_line )); then
    pass_test "smart 模式按 architecture 模板顺序插入新增 section"
else
    fail_test "architecture 新增 section 未按模板顺序插入" "$(cat "$target")"
fi

target="$TEST_DIR/invalid-mode.md"
"$SCRIPT_DIR/merge-document.sh" "$target" "内容" --mode=invalid >/dev/null 2>&1 && fail_test "无效模式应报错" || pass_test "无效模式正确报错"

echo "stdin内容" | "$SCRIPT_DIR/merge-document.sh" "$TEST_DIR/stdin-test.md" - --mode=append >/dev/null 2>&1
grep -q "stdin内容" "$TEST_DIR/stdin-test.md" && pass_test "stdin 输入正确" || fail_test "stdin 输入失败"

"$SCRIPT_DIR/merge-document.sh" --help 2>&1 | grep -q "智能" && pass_test "帮助信息正确" || fail_test "帮助信息不正确"

echo ""
log_info "=== 集成测试 ==="

docs=$("$SCRIPT_DIR/ensure-docs-dir.sh" "$TEST_DIR" 2>&1)
target="$docs/memory.md"
"$SCRIPT_DIR/merge-document.sh" "$target" "记忆内容" --mode=smart >/dev/null 2>&1

[[ -d "$docs" && -f "$target" ]] && grep -q "记忆内容" "$target" && pass_test "完整流程测试通过" || fail_test "完整流程失败"

echo ""
log_info "=== 文档模板结构测试 ==="

business_template="$SCRIPT_DIR/../assets/document-templates/business.md"
for field in "## 业务目标与存在理由" "## 核心业务对象" "## 不可破坏的业务规则" "## 关键业务流程" "## 成功定义" "## 业务边界与非目标" "## 已验证的业务判断" "## 更新日志"; do
    grep -qF "$field" "$business_template" && pass_test "business 模板包含字段: $field" || fail_test "business 模板缺少字段: $field"
done

product_template="$SCRIPT_DIR/../assets/document-templates/product.md"
for field in "## 目标用户与使用角色" "## 核心任务（JTBD）" "## 核心场景" "## 需求优先级原则" "## 关键体验原则" "## 关键取舍与拒绝事项" "## 已知用户坑点" "## 验收与成功信号" "## 更新日志"; do
    grep -qF "$field" "$product_template" && pass_test "product 模板包含字段: $field" || fail_test "product 模板缺少字段: $field"
done

grep -qF "## 功能矩阵" "$product_template" && fail_test "product 模板不应再包含功能矩阵" || pass_test "product 模板已移除功能矩阵"
grep -qF "负责人" "$product_template" && fail_test "product 模板不应再包含负责人栏位" || pass_test "product 模板已移除负责人栏位"

architecture_template="$SCRIPT_DIR/../assets/document-templates/architecture.md"
for field in "## 系统目标与架构边界" "## 核心组件与职责" "## 关键数据流与控制流" "## 关键技术决策" "## 依赖与外部系统" "## 扩展点与演进策略" "## 运行与操作约束" "## 已验证的架构判断" "## 更新日志"; do
    grep -qF "$field" "$architecture_template" && pass_test "architecture 模板包含字段: $field" || fail_test "architecture 模板缺少字段: $field"
done

grep -qF "## 部署架构" "$architecture_template" && fail_test "architecture 模板不应保留旧的部署架构孤立章节" || pass_test "architecture 模板已移除旧的部署架构孤立章节"
grep -qF "## 数据流" "$architecture_template" && fail_test "architecture 模板不应保留过于笼统的数据流章节" || pass_test "architecture 模板已改为关键数据流与控制流"

learnings_template="$SCRIPT_DIR/../assets/document-templates/learnings.md"
for field in "## 高价值失败模式" "## 调试与诊断启发式" "## 关键决策教训" "## Review 与交接检查清单" "## 已验证的有效实践" "## 更新日志"; do
    grep -qF "$field" "$learnings_template" && pass_test "learnings 模板包含字段: $field" || fail_test "learnings 模板缺少字段: $field"
done

grep -qF "## 按领域分类" "$learnings_template" && fail_test "learnings 模板不应保留按领域分类流水账结构" || pass_test "learnings 模板已移除按领域分类流水账结构"
grep -qF "## 问题统计" "$learnings_template" && fail_test "learnings 模板不应保留问题统计表" || pass_test "learnings 模板已移除问题统计表"

echo ""
log_info "=== Prompt 结构测试 ==="

prompt_file="$SCRIPT_DIR/../prompts/memory-generation.md"
for field in \
    "长期有效的业务认知" \
    "长期复用的产品判断框架" \
    "长期复用的架构认知与决策约束" \
    "长期复用的失败模式、诊断启发式与交付教训" \
    "只有当本次变更改变了长期业务认知时" \
    "只有当本次变更改变了长期产品认知时" \
    "只有当本次变更改变了长期架构认知时" \
    "只有当本次变更改变了长期经验认知时" \
    "notes" \
    "checkpoint_feedback" \
    "review_feedback" \
    '禁止把 `Added/Modified/Removed` 清单' \
    "禁止把单次 API 变更、零散依赖列表或部署流水账当作正文主体" \
    "禁止把逐日流水账、耗时记录、零散 bug 列表或临时情绪化结论写成正文" \
    '只追加 `## 更新日志`'; do
    grep -qF "$field" "$prompt_file" && pass_test "prompt 包含规则: $field" || fail_test "prompt 缺少规则: $field"
done

subagent_prompt="$SCRIPT_DIR/../prompts/memory-generation-subagent.md"
for field in \
    "memory generation 专用 subagent" \
    "只沉淀长期复用的信息" \
    "checkpoint_feedback" \
    "review_feedback" \
    '"{SCRIPT_DIR}/merge-document.sh"' \
    "STATUS: COMPLETED|SKIPPED|BLOCKED" \
    "CHANGED_FILES:" \
    "不要把一次性流水账写进正文"; do
    grep -qF "$field" "$subagent_prompt" && pass_test "subagent prompt 包含规则: $field" || fail_test "subagent prompt 缺少规则: $field"
done

echo ""
log_info "=== render-memory-generation-prompt.sh 测试 ==="

render_repo="$TEST_DIR/render-repo"
mkdir -p "$render_repo/openspec/changes/CHANGE-123/workflow-state"
git init "$render_repo" >/dev/null 2>&1
git -C "$render_repo" config user.name "OpsX Test"
git -C "$render_repo" config user.email "opsx-test@example.com"
printf "# state\n" > "$render_repo/openspec/changes/CHANGE-123/workflow-state/current-workflow-state.md"
printf "# audit\n" > "$render_repo/openspec/changes/CHANGE-123/workflow-state/audit-log.md"
printf "# plan\n" > "$render_repo/openspec/changes/CHANGE-123/workflow-state/current-plan.md"
cat > "$render_repo/openspec/changes/CHANGE-123/workflow-state/current-workflow-state.md" <<'EOF'
# Current workflow state

- `notes`: `总结：review 前先看证据，不要凭印象判断`
- `checkpoint_feedback`: `用户反馈：补充交接检查项`
- `review_feedback`: `review 指出需要沉淀失败模式`
EOF
mkdir -p "$render_repo/docs"
printf "seed\n" > "$render_repo/README.md"
git -C "$render_repo" add README.md
git -C "$render_repo" commit -m "chore: seed" >/dev/null 2>&1
git -C "$render_repo" checkout -b feature/memory >/dev/null 2>&1

rendered_prompt="$TEST_DIR/rendered-memory-prompt.md"
bash "$SCRIPT_DIR/render-memory-generation-prompt.sh" "CHANGE-123" "$render_repo" "$rendered_prompt" >/dev/null

grep -qF "$render_repo/docs/business.md" "$rendered_prompt" && pass_test "rendered prompt 注入 docs 路径" || fail_test "rendered prompt 未注入 docs 路径"
grep -qF "$render_repo/openspec/changes/CHANGE-123/workflow-state" "$rendered_prompt" && pass_test "rendered prompt 注入 workflow-state 路径" || fail_test "rendered prompt 未注入 workflow-state 路径"
grep -qF "git -C \"$render_repo\" diff \"main\"...HEAD --stat" "$rendered_prompt" && pass_test "rendered prompt 注入 diff 命令" || fail_test "rendered prompt 未注入 diff 命令"
grep -qF "$SCRIPT_DIR/merge-document.sh" "$rendered_prompt" && pass_test "rendered prompt 注入 merge-document 脚本路径" || fail_test "rendered prompt 未注入 merge-document 脚本路径"
grep -qF "STATUS: COMPLETED|SKIPPED|BLOCKED" "$rendered_prompt" && pass_test "rendered prompt 保留输出契约" || fail_test "rendered prompt 丢失输出契约"
grep -qF "workflow notes: 总结：review 前先看证据，不要凭印象判断" "$rendered_prompt" && pass_test "rendered prompt 注入对话 notes" || fail_test "rendered prompt 未注入对话 notes"
grep -qF "checkpoint feedback: 用户反馈：补充交接检查项" "$rendered_prompt" && pass_test "rendered prompt 注入 checkpoint feedback" || fail_test "rendered prompt 未注入 checkpoint feedback"
grep -qF "review feedback: review 指出需要沉淀失败模式" "$rendered_prompt" && pass_test "rendered prompt 注入 review feedback" || fail_test "rendered prompt 未注入 review feedback"

echo ""
echo "========================================"
echo -e "  ${BLUE}测试摘要${NC}"
echo "========================================"
echo -e "  运行: ${TESTS_RUN}"
echo -e "  通过: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "  失败: ${RED}${TESTS_FAILED}${NC}"
echo "========================================"

[[ $TESTS_FAILED -eq 0 ]] && echo -e "  ${GREEN}所有测试通过!${NC}" && exit 0 || echo -e "  ${RED}有测试失败${NC}" && exit 1
