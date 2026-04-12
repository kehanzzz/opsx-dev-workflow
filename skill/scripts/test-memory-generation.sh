#!/usr/bin/env bash

set -eo pipefail

# 在测试函数中，我们允许命令返回非零退出码
# 这是测试错误处理的正常情况
disable_exit_on_error() {
    set +e
}

enable_exit_on_error() {
    set -e
}

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

SCRIPT_DIR=""
TEST_DIR=""
FIXTURE_DIR=""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_error() { echo -e "${RED}[FAIL]${NC} $1"; }

pass_test() {
    ((TESTS_RUN++)) || true
    ((TESTS_PASSED++)) || true
    log_success "$1"
}

fail_test() {
    ((TESTS_RUN++)) || true
    ((TESTS_FAILED++)) || true
    log_error "$1"
    if [[ -n "${2:-}" ]]; then
        log_error "  详情: $2"
    fi
}

setup_test_env() {
    log_info "创建临时测试环境..."
    
    TEST_DIR=$(mktemp -d)
    FIXTURE_DIR="$SCRIPT_DIR/../tests/memory-fixtures"
    
    git init "$TEST_DIR" >/dev/null 2>&1 || true
    
    log_info "测试目录: $TEST_DIR"
}

cleanup_test_env() {
    log_info "清理测试环境..."
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
        log_success "已清理: $TEST_DIR"
    fi
}

# ============================================
# get-project-root.sh 测试
# ============================================

test_get_project_root_from_subdir() {
    log_info "=== 测试从子目录查找项目根目录 ==="
    
    local subdir="$TEST_DIR/src/lib"
    mkdir -p "$subdir"
    
    local result
    result=$("$SCRIPT_DIR/get-project-root.sh" "$subdir" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 && "$result" == "$TEST_DIR" ]]; then
        pass_test "从子目录正确找到项目根目录"
    else
        fail_test "从子目录查找项目根目录失败" "期望: $TEST_DIR, 实际: $result, 退出码: $exit_code"
    fi
}

test_get_project_root_from_root() {
    log_info "=== 测试从项目根目录查找 ==="
    
    local result
    result=$("$SCRIPT_DIR/get-project-root.sh" "$TEST_DIR" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 && "$result" == "$TEST_DIR" ]]; then
        pass_test "从项目根目录正确返回"
    else
        fail_test "从项目根目录查找失败" "期望: $TEST_DIR, 实际: $result"
    fi
}

test_get_project_root_nongit() {
    log_info "=== 测试非 Git 仓库目录 ==="
    
    local not_git_dir="/tmp"
    if [[ -d "$not_git_dir" ]]; then
        disable_exit_on_error
        local result
        result=$("$SCRIPT_DIR/get-project-root.sh" "$not_git_dir" 2>&1)
        local exit_code=$?
        enable_exit_on_error
        
        if [[ $exit_code -ne 0 ]]; then
            pass_test "非 Git 仓库目录正确返回错误"
        else
            fail_test "非 Git 仓库目录未返回错误"
        fi
    else
        pass_test "跳过: /tmp 不存在"
    fi
}

test_get_project_root_help() {
    log_info "=== 测试帮助信息 ==="
    
    local output
    output=$("$SCRIPT_DIR/get-project-root.sh" --help 2>&1)
    
    if echo "$output" | grep -q "项目根目录"; then
        pass_test "帮助信息显示正确"
    else
        fail_test "帮助信息显示不正确"
    fi
}

# ============================================
# ensure-docs-dir.sh 测试
# ============================================

test_ensure_docs_dir_new() {
    log_info "=== 测试创建新的 docs 目录 ==="
    
    local result
    result=$("$SCRIPT_DIR/ensure-docs-dir.sh" "$TEST_DIR" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 && -d "$result" ]]; then
        pass_test "成功创建新的 docs 目录"
    else
        fail_test "创建 docs 目录失败" "结果: $result"
    fi
}

test_ensure_docs_dir_existing() {
    log_info "=== 测试已存在的 docs 目录 ==="
    
    # 先创建 docs 目录
    mkdir -p "$TEST_DIR/docs"
    
    local result
    result=$("$SCRIPT_DIR/ensure-docs-dir.sh" "$TEST_DIR" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 && "$result" == "$TEST_DIR/docs" ]]; then
        pass_test "已存在 docs 目录时正确返回"
    else
        fail_test "已存在 docs 目录处理不正确" "结果: $result"
    fi
}

test_ensure_docs_dir_invalid_root() {
    log_info "=== 测试无效项目根目录 ==="
    
    disable_exit_on_error
    local result
    result=$("$SCRIPT_DIR/ensure-docs-dir.sh" "/nonexistent/path" 2>&1)
    local exit_code=$?
    enable_exit_on_error
    
    if [[ $exit_code -ne 0 ]]; then
        pass_test "无效项目根目录正确返回错误"
    else
        fail_test "无效项目根目录未返回错误"
    fi
}

test_ensure_docs_dir_help() {
    log_info "=== 测试帮助信息 ==="
    
    local output
    output=$("$SCRIPT_DIR/ensure-docs-dir.sh" --help 2>&1)
    
    if echo "$output" | grep -q "docs"; then
        pass_test "帮助信息显示正确"
    else
        fail_test "帮助信息显示不正确"
    fi
}

# ============================================
# merge-document.sh 测试
# ============================================

test_merge_new_document() {
    log_info "=== 测试创建新文档 ==="
    
    local target="$TEST_DIR/new-doc.md"
    local content="这是测试内容"
    
    local result
    result=$("$SCRIPT_DIR/merge-document.sh" "$target" "$content" --mode=smart 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 && -f "$target" ]]; then
        if grep -q "$content" "$target"; then
            pass_test "成功创建新文档"
        else
            fail_test "文档内容不正确"
        fi
    else
        fail_test "创建新文档失败" "退出码: $exit_code"
    fi
}

test_merge_append_mode() {
    log_info "=== 测试追加模式 ==="
    
    local target="$TEST_DIR/append-test.md"
    echo "原始内容" > "$target"
    
    local content="追加内容"
    "$SCRIPT_DIR/merge-document.sh" "$target" "$content" --mode=append >/dev/null 2>&1
    
    if grep -q "原始内容" "$target" && grep -q "追加内容" "$target"; then
        pass_test "追加模式正确工作"
    else
        fail_test "追加模式不正确"
    fi
}

test_merge_prepend_mode() {
    log_info "=== 测试前置模式 ==="
    
    local target="$TEST_DIR/prepend-test.md"
    echo "原始内容" > "$target"
    
    local content="前置内容"
    "$SCRIPT_DIR/merge-document.sh" "$target" "$content" --mode=prepend >/dev/null 2>&1
    
    local first_line
    first_line=$(head -n 1 "$target")
    
    if [[ "$first_line" == "前置内容" ]]; then
        pass_test "前置模式正确工作"
    else
        fail_test "前置模式不正确" "首行: $first_line"
    fi
}

test_merge_smart_mode() {
    log_info "=== 测试智能合并模式 ==="
    
    local target="$TEST_DIR/smart-test.md"
    cat > "$target" << 'EOF'
# 测试文档

## 概述
这是一个测试文档。

## 变更历史
### 2026-01-01
初始版本
EOF
    
    local new_content="添加了新功能"
    "$SCRIPT_DIR/merge-document.sh" "$target" "$new_content" --mode=smart >/dev/null 2>&1
    
    if grep -q "添加了新功能" "$target"; then
        pass_test "智能合并模式正确工作"
    else
        fail_test "智能合并模式不正确"
    fi
}

test_merge_smart_new_changelog() {
    log_info "=== 测试智能合并创建变更历史 ==="
    
    local target="$TEST_DIR/changelog-test.md"
    echo "# 测试文档" > "$target"
    
    local new_content="首次提交"
    "$SCRIPT_DIR/merge-document.sh" "$target" "$new_content" --mode=smart >/dev/null 2>&1
    
    if grep -q "变更历史" "$target" && grep -q "首次提交" "$target"; then
        pass_test "智能合并创建变更历史部分"
    else
        fail_test "智能合并未创建变更历史"
    fi
}

test_merge_invalid_mode() {
    log_info "=== 测试无效合并模式 ==="
    
    local target="$TEST_DIR/test.md"
    local content="测试内容"
    
    disable_exit_on_error
    local result
    result=$("$SCRIPT_DIR/merge-document.sh" "$target" "$content" --mode=invalid 2>&1)
    local exit_code=$?
    enable_exit_on_error
    
    if [[ $exit_code -ne 0 ]]; then
        pass_test "无效合并模式正确返回错误"
    else
        fail_test "无效合并模式未返回错误"
    fi
}

test_merge_stdin_input() {
    log_info "=== 测试从 stdin 读取内容 ==="
    
    local target="$TEST_DIR/stdin-test.md"
    local content="通过 stdin 输入的内容"
    
    echo "$content" | "$SCRIPT_DIR/merge-document.sh" "$target" - --mode=append >/dev/null 2>&1
    
    if grep -q "$content" "$target"; then
        pass_test "从 stdin 读取内容正确"
    else
        fail_test "从 stdin 读取内容失败"
    fi
}

test_merge_help() {
    log_info "=== 测试帮助信息 ==="
    
    local output
    output=$("$SCRIPT_DIR/merge-document.sh" --help 2>&1)
    
    if echo "$output" | grep -q "智能"; then
        pass_test "帮助信息显示正确"
    else
        fail_test "帮助信息显示不正确"
    fi
}

# ============================================
# 集成测试
# ============================================

test_integration_full_flow() {
    log_info "=== 测试完整流程 ==="
    
    # 1. 获取项目根目录
    local root_result
    root_result=$("$SCRIPT_DIR/get-project-root.sh" "$TEST_DIR" 2>&1)
    
    # 2. 确保 docs 目录存在
    local docs_result
    docs_result=$("$SCRIPT_DIR/ensure-docs-dir.sh" "$TEST_DIR" 2>&1)
    
    # 3. 创建并合并文档
    local target="$docs_result/memory.md"
    local content="测试记忆文档内容"
    "$SCRIPT_DIR/merge-document.sh" "$target" "$content" --mode=smart >/dev/null 2>&1
    
    # 验证
    if [[ -d "$docs_result" && -f "$target" ]]; then
        if grep -q "$content" "$target"; then
            pass_test "完整流程测试通过"
        else
            fail_test "文档内容不正确"
        fi
    else
        fail_test "完整流程失败"
    fi
}

# ============================================
# 测试摘要
# ============================================

print_summary() {
    echo ""
    echo "========================================"
    echo -e "  ${BLUE}测试摘要${NC}"
    echo "========================================"
    echo -e "  运行: ${TESTS_RUN}"
    echo -e "  通过: ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "  失败: ${RED}${TESTS_FAILED}${NC}"
    echo "========================================"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "  ${GREEN}所有测试通过!${NC}"
        return 0
    else
        echo -e "  ${RED}有测试失败${NC}"
        return 1
    fi
}

main() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    echo ""
    echo "========================================"
    echo -e "  ${BLUE}记忆生成功能单元测试${NC}"
    echo "========================================"
    echo ""
    
    trap cleanup_test_env EXIT
    
    setup_test_env
    
    # get-project-root.sh 测试
    test_get_project_root_from_subdir
    test_get_project_root_from_root
    test_get_project_root_nongit
    test_get_project_root_help
    
    # ensure-docs-dir.sh 测试
    test_ensure_docs_dir_new
    test_ensure_docs_dir_existing
    test_ensure_docs_dir_invalid_root
    test_ensure_docs_dir_help
    
    # merge-document.sh 测试
    test_merge_new_document
    test_merge_append_mode
    test_merge_prepend_mode
    test_merge_smart_mode
    test_merge_smart_new_changelog
    test_merge_invalid_mode
    test_merge_stdin_input
    test_merge_help
    
    # 集成测试
    test_integration_full_flow
    
    print_summary
}

main "$@"