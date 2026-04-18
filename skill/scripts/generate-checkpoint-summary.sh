#!/bin/bash

# 用法: generate-checkpoint-summary.sh <phase_name> <change_id> [custom_summary] [project_root]
# 示例:
#   ./generate-checkpoint-summary.sh planning CHG-123
#   ./generate-checkpoint-summary.sh execution CHG-456 "自定义成果描述"

show_help() {
    cat << 'EOF'
检查点摘要生成脚本

用法:
    generate-checkpoint-summary.sh <phase_name> <change_id> [custom_summary] [project_root]

参数:
    phase_name      阶段名称 (explore, branch-setup, change-and-spec,
                              planning, execution, code-review,
                              verification, finalization)
    change_id       变更 ID
    custom_summary  可选的自定义摘要文本
    project_root    可选的项目根目录（包含 openspec/）
EOF
}

discover_project_root() {
    local dir="${1:-$PWD}"

    if [[ -n "$dir" && -d "$dir/openspec" ]]; then
        printf '%s\n' "$dir"
        return 0
    fi

    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/openspec" ]]; then
            printf '%s\n' "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    return 1
}

get_field() {
    local file="$1"
    local field="$2"

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    sed -n "s/^- \`${field}\`: \`\\(.*\\)\`$/\\1/p" "$file" | head -n 1
}

append_line() {
    local current="$1"
    local line="$2"

    if [[ -z "$line" ]]; then
        printf '%s' "$current"
        return 0
    fi

    if [[ -z "$current" ]]; then
        printf '%s' "$line"
    else
        printf '%s\n%s' "$current" "$line"
    fi
}

build_state_achievements() {
    local workflow_file="$1"
    local plan_file="$2"
    local task_file="$3"
    local result=""
    local current_phase execution_mode external_tool spec_path plan_path current_task_id next_action last_verified_at notes
    local review_round review_max_rounds review_loop_status review_base_sha review_head_sha
    local finalization_stage memory_generation_status archive_status branch_finish_status
    local plan_summary tasks_total tasks_completed tasks_blocked plan_drift_detected
    local task_id task_goal task_status review_status

    current_phase="$(get_field "$workflow_file" current_phase)"
    execution_mode="$(get_field "$workflow_file" execution_mode)"
    external_tool="$(get_field "$workflow_file" external_tool)"
    spec_path="$(get_field "$workflow_file" spec_path)"
    plan_path="$(get_field "$workflow_file" plan_path)"
    current_task_id="$(get_field "$workflow_file" current_task_id)"
    next_action="$(get_field "$workflow_file" next_action)"
    last_verified_at="$(get_field "$workflow_file" last_verified_at)"
    notes="$(get_field "$workflow_file" notes)"
    review_round="$(get_field "$workflow_file" review_round)"
    review_max_rounds="$(get_field "$workflow_file" review_max_rounds)"
    review_loop_status="$(get_field "$workflow_file" review_loop_status)"
    review_base_sha="$(get_field "$workflow_file" review_base_sha)"
    review_head_sha="$(get_field "$workflow_file" review_head_sha)"
    finalization_stage="$(get_field "$workflow_file" finalization_stage)"
    memory_generation_status="$(get_field "$workflow_file" memory_generation_status)"
    archive_status="$(get_field "$workflow_file" archive_status)"
    branch_finish_status="$(get_field "$workflow_file" branch_finish_status)"

    plan_summary="$(get_field "$plan_file" plan_summary)"
    tasks_total="$(get_field "$plan_file" tasks_total)"
    tasks_completed="$(get_field "$plan_file" tasks_completed)"
    tasks_blocked="$(get_field "$plan_file" tasks_blocked)"
    plan_drift_detected="$(get_field "$plan_file" plan_drift_detected)"

    task_id="$(get_field "$task_file" task_id)"
    task_goal="$(get_field "$task_file" task_goal)"
    task_status="$(get_field "$task_file" task_status)"
    review_status="$(get_field "$task_file" review_status)"

    if [[ -n "$current_phase" && "$current_phase" != "UNSET" ]]; then
        result="$(append_line "$result" "- 当前记录阶段: $current_phase")"
    fi

    if [[ -n "$spec_path" && "$spec_path" != "UNSET" ]]; then
        result="$(append_line "$result" "- 规格路径: $spec_path")"
    fi

    if [[ -n "$plan_path" && "$plan_path" != "UNSET" ]]; then
        result="$(append_line "$result" "- 计划路径: $plan_path")"
    fi

    if [[ -n "$plan_summary" && "$plan_summary" != "UNSET" ]]; then
        result="$(append_line "$result" "- 计划摘要: $plan_summary")"
    fi

    if [[ -n "$tasks_total" && "$tasks_total" != "0" ]]; then
        result="$(append_line "$result" "- 任务进度: ${tasks_completed:-0}/$tasks_total")"
    fi

    if [[ -n "$tasks_blocked" && "$tasks_blocked" != "0" ]]; then
        result="$(append_line "$result" "- 阻塞任务数: $tasks_blocked")"
    fi

    if [[ -n "$task_id" && "$task_id" != "UNSET" ]]; then
        result="$(append_line "$result" "- 当前任务: $task_id")"
    elif [[ -n "$current_task_id" && "$current_task_id" != "UNSET" ]]; then
        result="$(append_line "$result" "- 当前任务: $current_task_id")"
    fi

    if [[ -n "$task_goal" && "$task_goal" != "UNSET" ]]; then
        result="$(append_line "$result" "- 当前任务目标: $task_goal")"
    fi

    if [[ -n "$task_status" && "$task_status" != "UNSET" ]]; then
        result="$(append_line "$result" "- 当前任务状态: $task_status")"
    fi

    if [[ -n "$review_status" && "$review_status" != "UNSET" ]]; then
        result="$(append_line "$result" "- 评审结论: $review_status")"
    fi

    if [[ -n "$review_round" && "$review_round" != "UNSET" ]]; then
        if [[ -n "$review_max_rounds" && "$review_max_rounds" != "UNSET" ]]; then
            result="$(append_line "$result" "- Review 轮次: $review_round/$review_max_rounds")"
        else
            result="$(append_line "$result" "- Review 轮次: $review_round")"
        fi
    fi

    if [[ -n "$review_loop_status" && "$review_loop_status" != "UNSET" ]]; then
        result="$(append_line "$result" "- Review 循环状态: $review_loop_status")"
    fi

    if [[ -n "$review_base_sha" && "$review_base_sha" != "UNSET" && -n "$review_head_sha" && "$review_head_sha" != "UNSET" ]]; then
        result="$(append_line "$result" "- Review 范围: ${review_base_sha:0:7}..${review_head_sha:0:7}")"
    fi

    if [[ -n "$finalization_stage" && "$finalization_stage" != "UNSET" ]]; then
        result="$(append_line "$result" "- Finalization 当前子阶段: $finalization_stage")"
    fi

    if [[ -n "$memory_generation_status" && "$memory_generation_status" != "UNSET" ]]; then
        result="$(append_line "$result" "- Memory generation 状态: $memory_generation_status")"
    fi

    if [[ -n "$archive_status" && "$archive_status" != "UNSET" ]]; then
        result="$(append_line "$result" "- Archive 状态: $archive_status")"
    fi

    if [[ -n "$branch_finish_status" && "$branch_finish_status" != "UNSET" ]]; then
        result="$(append_line "$result" "- Branch finish 状态: $branch_finish_status")"
    fi

    if [[ -n "$execution_mode" && "$execution_mode" != "UNSET" ]]; then
        result="$(append_line "$result" "- 执行模式: $execution_mode")"
    fi

    if [[ -n "$external_tool" && "$external_tool" != "UNSET" ]]; then
        result="$(append_line "$result" "- 外部工具: $external_tool")"
    fi

    if [[ -n "$last_verified_at" && "$last_verified_at" != "UNSET" ]]; then
        result="$(append_line "$result" "- 最近验证时间: $last_verified_at")"
    fi

    if [[ -n "$plan_drift_detected" && "$plan_drift_detected" != "UNSET" && "$plan_drift_detected" != "false" ]]; then
        result="$(append_line "$result" "- 计划漂移: $plan_drift_detected")"
    fi

    if [[ -n "$notes" && "$notes" != "UNSET" && "$notes" != "Update this file immediately after each phase transition" ]]; then
        result="$(append_line "$result" "- 备注: $notes")"
    fi

    printf '%s\n' "$result"
}

get_phase_description() {
    case "$1" in
        explore) echo "探索阶段" ;;
        branch-setup) echo "分支设置" ;;
        change-and-spec) echo "变更与规范" ;;
        planning) echo "规划阶段" ;;
        execution) echo "执行阶段" ;;
        code-review) echo "代码评审" ;;
        verification) echo "验证阶段" ;;
        finalization) echo "最终收尾阶段" ;;
        *) echo "$1" ;;
    esac
}

get_default_achievements() {
    local phase="$1"
    local custom="$2"
    
    if [ -n "$custom" ]; then
        echo "$custom"
        return
    fi
    
    case "$phase" in
        explore)
            echo "- 完成需求分析"
            echo "- 确认技术方案"
            echo "- 识别潜在风险"
            ;;
        branch-setup)
            echo "- 创建功能分支"
            echo "- 配置开发环境"
            echo "- 初始化变更记录"
            ;;
        change-and-spec)
            echo "- 编写变更规范"
            echo "- 创建实现计划"
            echo "- 确认验收标准"
            ;;
        planning)
            echo "- 制定实现计划"
            echo "- 估算工作量"
            echo "- 分配任务"
            ;;
        execution)
            echo "- 完成代码实现"
            echo "- 编写单元测试"
            echo "- 集成测试通过"
            ;;
        code-review)
            echo "- 完成代码评审"
            echo "- 整理评审结论"
            echo "- 修复关键反馈"
            ;;
        verification)
            echo "- 功能测试通过"
            echo "- 性能测试达标"
            echo "- 文档已更新"
            ;;
        finalization)
            echo "- 收尾动作已准备就绪"
            echo "- 归档与分支结束动作已排定"
            echo "- 最终收尾条件已确认"
            ;;
    esac
}

get_next_steps() {
    local phase="$1"
    
    case "$phase" in
        explore)
            echo "- 进入规划阶段"
            echo "- 确认时间计划"
            ;;
        branch-setup)
            echo "- 开始实现工作"
            echo "- 确认依赖项"
            ;;
        change-and-spec)
            echo "- 提交规范审批"
            echo "- 确认评审意见"
            ;;
        planning)
            echo "- 开始开发迭代"
            echo "- 确认资源分配"
            ;;
        execution)
            echo "- 提交代码审查"
            echo "- 修复审查反馈"
            ;;
        code-review)
            echo "- 进入验证阶段"
            echo "- 运行仓库级验证"
            ;;
        verification)
            echo "- 准备发布"
            echo "- 确认部署计划"
            ;;
        finalization)
            echo "- 任务完成"
            echo "- 执行最终归档与分支结束流程"
            ;;
    esac
}

build_state_next_steps() {
    local workflow_file="$1"
    local next_action

    next_action="$(get_field "$workflow_file" next_action)"

    if [[ -n "$next_action" && "$next_action" != "UNSET" ]]; then
        printf '%s\n' "- 下一允许动作: $next_action"
        printf '%s\n' "- 若实际状态已变化，先同步 workflow-state 后再继续推进"
    fi
}

validate_phase() {
    local phase="$1"
    local valid_phases="explore branch-setup change-and-spec planning execution code-review verification finalization"
    
    for valid in $valid_phases; do
        if [ "$phase" = "$valid" ]; then
            return 0
        fi
    done
    return 1
}

if [ $# -lt 2 ]; then
    show_help
    exit 1
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

PHASE_NAME="$1"
CHANGE_ID="$2"
CUSTOM_SUMMARY="${3:-}"
PROJECT_ROOT="${4:-}"

if ! validate_phase "$PHASE_NAME"; then
    echo "错误: 无效的阶段名称 '$PHASE_NAME'" >&2
    exit 1
fi

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
PHASE_DESC=$(get_phase_description "$PHASE_NAME")
ACHIEVEMENTS=""
NEXT_STEPS=""

if [[ -n "$PROJECT_ROOT" ]] || PROJECT_ROOT="$(discover_project_root "$PWD")"; then
    STATE_DIR="$PROJECT_ROOT/openspec/changes/$CHANGE_ID/workflow-state"
    WORKFLOW_FILE="$STATE_DIR/current-workflow-state.md"
    PLAN_FILE="$STATE_DIR/current-plan.md"
    TASK_FILE="$STATE_DIR/current-task.md"

    if [[ -z "$CUSTOM_SUMMARY" && -f "$WORKFLOW_FILE" ]]; then
        ACHIEVEMENTS="$(build_state_achievements "$WORKFLOW_FILE" "$PLAN_FILE" "$TASK_FILE")"
        NEXT_STEPS="$(build_state_next_steps "$WORKFLOW_FILE")"
    fi
fi

if [[ -z "$ACHIEVEMENTS" ]]; then
    ACHIEVEMENTS=$(get_default_achievements "$PHASE_NAME" "$CUSTOM_SUMMARY")
fi

if [[ -z "$NEXT_STEPS" ]]; then
    NEXT_STEPS=$(get_next_steps "$PHASE_NAME")
fi

cat << EOF
## 检查点摘要: $PHASE_DESC

**变更 ID**: $CHANGE_ID  
**完成时间**: $TIMESTAMP  
**阶段**: $PHASE_NAME

### 主要成果
$ACHIEVEMENTS

### 待确认事项
$NEXT_STEPS

---
*此摘要由 generate-checkpoint-summary.sh 自动生成*
EOF
