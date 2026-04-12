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

TEST_DIR=""
SCRIPT_DIR=""

PHASES=("explore" "branch-setup" "change-and-spec" "planning" "execution" "verification" "archive" "branch-finish")

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
    log_info "测试目录: $TEST_DIR"
}

cleanup_test_env() {
    log_info "清理测试环境..."
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
        log_success "已清理: $TEST_DIR"
    fi
}

test_generate_summary() {
    log_info "=== 测试生成检查点摘要 ==="
    
    for phase in "${PHASES[@]}"; do
        local output
        output=$("$SCRIPT_DIR/generate-checkpoint-summary.sh" "$phase" "TEST-001" 2>&1) || true
        
        if echo "$output" | grep -q "检查点摘要:"; then
            pass_test "生成阶段 [$phase] 的摘要成功"
        else
            fail_test "生成阶段 [$phase] 的摘要输出格式错误"
        fi
        
        if echo "$output" | grep -q "TEST-001"; then
            pass_test "阶段 [$phase] 包含正确的变更ID"
        else
            fail_test "阶段 [$phase] 缺少变更ID"
        fi
    done
}

test_custom_summary() {
    log_info "=== 测试自定义摘要 ==="
    
    local output
    output=$("$SCRIPT_DIR/generate-checkpoint-summary.sh" "planning" "TEST-001" "完成核心功能开发" 2>&1)
    
    if echo "$output" | grep -q "完成核心功能开发"; then
        pass_test "自定义摘要内容正确"
    else
        fail_test "自定义摘要内容不正确" "$output"
    fi
}

test_invalid_phase() {
    log_info "=== 测试无效阶段处理 ==="
    
    local output
    output=$("$SCRIPT_DIR/generate-checkpoint-summary.sh" "invalid_phase" "TEST-001" 2>&1) || true
    
    if echo "$output" | grep -qE "(错误|Invalid|error)"; then
        pass_test "无效阶段正确报错"
    else
        fail_test "无效阶段未正确报错" "$output"
    fi
}

test_phase_descriptions() {
    log_info "=== 测试阶段描述正确性 ==="
    
    local test_cases=(
        "explore:探索阶段"
        "branch-setup:分支设置"
        "change-and-spec:变更与规范"
        "planning:规划阶段"
        "execution:执行阶段"
        "verification:验证阶段"
        "archive:归档阶段"
        "branch-finish:分支完成"
    )
    
    for tc in "${test_cases[@]}"; do
        local phase="${tc%%:*}"
        local expected_desc="${tc##*:}"
        
        local output
        output=$("$SCRIPT_DIR/generate-checkpoint-summary.sh" "$phase" "TEST-001" 2>&1)
        
        if echo "$output" | grep -q "$expected_desc"; then
            pass_test "阶段 [$phase] 描述正确: $expected_desc"
        else
            fail_test "阶段 [$phase] 描述不正确，期望: $expected_desc"
        fi
    done
}

test_default_achievements() {
    log_info "=== 测试默认成果内容 ==="
    
    local test_cases=(
        "explore:完成需求分析"
        "execution:完成代码实现"
        "archive:代码已归档"
    )
    
    for tc in "${test_cases[@]}"; do
        local phase="${tc%%:*}"
        local expected="${tc##*:}"
        
        local output
        output=$("$SCRIPT_DIR/generate-checkpoint-summary.sh" "$phase" "TEST-001" 2>&1)
        
        if echo "$output" | grep -q "$expected"; then
            pass_test "阶段 [$phase] 包含默认成果: $expected"
        else
            fail_test "阶段 [$phase] 缺少默认成果: $expected"
        fi
    done
}

test_next_steps() {
    log_info "=== 测试待确认事项 ==="
    
    local test_cases=(
        "explore:进入规划阶段"
        "planning:开始开发迭代"
        "archive:清理开发分支"
    )
    
    for tc in "${test_cases[@]}"; do
        local phase="${tc%%:*}"
        local expected="${tc##*:}"
        
        local output
        output=$("$SCRIPT_DIR/generate-checkpoint-summary.sh" "$phase" "TEST-001" 2>&1)
        
        if echo "$output" | grep -q "$expected"; then
            pass_test "阶段 [$phase] 包含待确认事项: $expected"
        else
            fail_test "阶段 [$phase] 缺少待确认事项: $expected"
        fi
    done
}

test_summary_format() {
    log_info "=== 测试摘要输出格式 ==="
    
    local output
    output=$("$SCRIPT_DIR/generate-checkpoint-summary.sh" "planning" "TEST-001" 2>&1)
    
    local required_fields=("检查点摘要:" "变更 ID" "完成时间" "阶段" "主要成果" "待确认事项")
    
    for field in "${required_fields[@]}"; do
        if echo "$output" | grep -qF "$field"; then
            pass_test "摘要包含字段: $field"
        else
            fail_test "摘要缺少字段: $field"
        fi
    done
    
    if echo "$output" | grep -qE "^---$"; then
        pass_test "摘要包含分隔线"
    else
        fail_test "摘要缺少分隔线"
    fi
    
    if echo "$output" | grep -q "自动生成"; then
        pass_test "摘要包含生成标记"
    else
        fail_test "摘要缺少生成标记"
    fi
}

test_timestamp_format() {
    log_info "=== 测试时间戳格式 ==="
    
    local output
    output=$("$SCRIPT_DIR/generate-checkpoint-summary.sh" "planning" "TEST-001" 2>&1)
    
    if echo "$output" | grep -qE "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}"; then
        pass_test "时间戳格式正确 (YYYY-MM-DD HH:MM:SS)"
    else
        fail_test "时间戳格式不正确"
    fi
}

test_all_phases_summary() {
    log_info "=== 测试所有8个阶段摘要 ==="
    
    local expected_phases=("explore" "branch-setup" "change-and-spec" "planning" "execution" "verification" "archive" "branch-finish")
    
    for phase in "${expected_phases[@]}"; do
        local output
        output=$("$SCRIPT_DIR/generate-checkpoint-summary.sh" "$phase" "TEST-001" 2>&1)
        
        if echo "$output" | grep -qF "**阶段**: $phase"; then
            pass_test "阶段 [$phase] 在摘要中正确显示"
        else
            fail_test "阶段 [$phase] 在摘要中显示不正确"
        fi
    done
}

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
    echo -e "  ${BLUE}检查点流程集成测试${NC}"
    echo "========================================"
    echo ""
    
    trap cleanup_test_env EXIT
    
    setup_test_env
    
    test_generate_summary
    test_custom_summary
    test_invalid_phase
    test_phase_descriptions
    test_default_achievements
    test_next_steps
    test_summary_format
    test_timestamp_format
    test_all_phases_summary
    
    print_summary
}

main "$@"