#!/bin/bash

# 用法: generate-checkpoint-summary.sh <phase_name> <change_id> [custom_summary]
# 示例:
#   ./generate-checkpoint-summary.sh planning CHG-123
#   ./generate-checkpoint-summary.sh execution CHG-456 "自定义成果描述"

show_help() {
    cat << 'EOF'
检查点摘要生成脚本

用法:
    generate-checkpoint-summary.sh <phase_name> <change_id> [custom_summary]

参数:
    phase_name      阶段名称 (explore, branch-setup, change-and-spec, 
                              planning, execution, verification, 
                              archive, branch-finish)
    change_id       变更 ID
    custom_summary  可选的自定义摘要文本
EOF
}

get_phase_description() {
    case "$1" in
        explore) echo "探索阶段" ;;
        branch-setup) echo "分支设置" ;;
        change-and-spec) echo "变更与规范" ;;
        planning) echo "规划阶段" ;;
        execution) echo "执行阶段" ;;
        verification) echo "验证阶段" ;;
        archive) echo "归档阶段" ;;
        branch-finish) echo "分支完成" ;;
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
        verification)
            echo "- 功能测试通过"
            echo "- 性能测试达标"
            echo "- 文档已更新"
            ;;
        archive)
            echo "- 代码已归档"
            echo "- 文档已存档"
            echo "- 变更已关闭"
            ;;
        branch-finish)
            echo "- 分支已清理"
            echo "- 合并到主分支"
            echo "- 发布完成"
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
        verification)
            echo "- 准备发布"
            echo "- 确认部署计划"
            ;;
        archive)
            echo "- 清理开发分支"
            echo "- 更新主变更记录"
            ;;
        branch-finish)
            echo "- 任务完成"
            echo "- 总结经验教训"
            ;;
    esac
}

validate_phase() {
    local phase="$1"
    local valid_phases="explore branch-setup change-and-spec planning execution verification archive branch-finish"
    
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
CUSTOM_SUMMARY="$3"

if ! validate_phase "$PHASE_NAME"; then
    echo "错误: 无效的阶段名称 '$PHASE_NAME'" >&2
    exit 1
fi

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
PHASE_DESC=$(get_phase_description "$PHASE_NAME")
ACHIEVEMENTS=$(get_default_achievements "$PHASE_NAME" "$CUSTOM_SUMMARY")
NEXT_STEPS=$(get_next_steps "$PHASE_NAME")

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