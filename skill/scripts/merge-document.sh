#!/bin/bash

# 用法: merge-document.sh <target-file> <new-content> [--mode=append|prepend|smart]
# 说明: 智能合并新内容到现有文档
# 参数:
#   $1: 目标文档路径
#   $2: 新内容（或从 stdin 读取）
#   --mode: merge 模式（append/prepend/smart，默认 smart）
# 输出: 合并后的文档内容到 stdout
# 退出码: 0 成功，1 失败

set -o pipefail

show_help() {
    cat << 'EOF'
智能文档合并脚本

用法:
    merge-document.sh <target-file> <new-content> [--mode=mode]
    echo "<new-content>" | merge-document.sh <target-file> --mode=mode

参数:
    target-file    目标文档路径
    new-content    要合并的新内容（如果为 -，则从 stdin 读取）
    --mode         合并模式: append|prepend|smart (默认: smart)

模式说明:
    append         将新内容追加到文档末尾
    prepend        将新内容插入到文档开头
    smart          智能模式:
                  - 如果文档不存在，创建新文档
                  - 如果文档存在，检查变更历史部分
                  - 追加新的变更记录
                  - 更新相关领域内容（如果已存在则更新，不存在则追加）

退出码:
    0 - 成功
    1 - 失败

示例:
    ./merge-document.sh docs/architecture.md "new content" --mode=smart
    echo "new content" | ./merge-document.sh docs/notes.md --mode=append
EOF
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

TARGET_FILE="$1"
MODE="smart"

for arg in "$@"; do
    case "$arg" in
        --mode=*)
            MODE="${arg#--mode=}"
            ;;
    esac
done

if [ "$MODE" != "append" ] && [ "$MODE" != "prepend" ] && [ "$MODE" != "smart" ]; then
    echo "错误: 无效的合并模式 '$MODE'" >&2
    exit 1
fi

NEW_CONTENT="$2"

if [ "$NEW_CONTENT" = "-" ] || [ -z "$NEW_CONTENT" ] && [ ! -t 0 ]; then
    NEW_CONTENT="$(cat)"
fi

if [ -z "$NEW_CONTENT" ]; then
    echo "错误: 未提供新内容" >&2
    exit 1
fi

TARGET_DIR="$(dirname "$TARGET_FILE")"
if [ ! -d "$TARGET_DIR" ] && [ "$TARGET_DIR" != "." ]; then
    if ! mkdir -p "$TARGET_DIR" 2>/dev/null; then
        echo "错误: 无法创建目录: $TARGET_DIR" >&2
        exit 1
    fi
fi

smart_merge() {
    local target="$1"
    local content="$2"
    
    if [ ! -f "$target" ]; then
        echo "$content"
        return 0
    fi
    
    local existing
    existing="$(cat "$target")"
    
    local timestamp
    timestamp="$(date "+%Y-%m-%d %H:%M:%S")"
    
    local has_changelog=0
    if echo "$existing" | grep -qi "##.*变更"; then
        has_changelog=1
    fi
    
    if [ $has_changelog -eq 1 ]; then
        local heading_found=0
        local result=""
        local in_changelog=0
        
        while IFS= read -r line; do
            if [ $heading_found -eq 0 ] && echo "$line" | grep -q "^##"; then
                heading_found=1
            fi
            
            if [ $heading_found -eq 1 ] && [ $in_changelog -eq 0 ] && echo "$line" | grep -qi "^##.*变更"; then
                in_changelog=1
                echo "$line"
                echo ""
                echo "### $timestamp"
                echo "$content"
                echo ""
                continue
            fi
            
            result="${result}${line}"$'\n'
        done <<< "$existing"
        
        if [ $in_changelog -eq 0 ]; then
            echo "$existing"
            echo ""
            echo "## 变更历史"
            echo ""
            echo "### $timestamp"
            echo "$content"
        else
            echo -n "$result"
        fi
    else
        echo "$existing"
        echo ""
        echo "## 变更历史"
        echo ""
        echo "### $timestamp"
        echo "$content"
    fi
}

case "$MODE" in
    append)
        {
            if [ -f "$TARGET_FILE" ]; then
                cat "$TARGET_FILE"
                echo ""
            fi
            echo "$NEW_CONTENT"
        } > "$TARGET_FILE.tmp" && mv "$TARGET_FILE.tmp" "$TARGET_FILE"
        ;;
    prepend)
        {
            echo "$NEW_CONTENT"
            if [ -f "$TARGET_FILE" ]; then
                echo ""
                cat "$TARGET_FILE"
            fi
        } > "$TARGET_FILE.tmp" && mv "$TARGET_FILE.tmp" "$TARGET_FILE"
        ;;
    smart)
        smart_merge "$TARGET_FILE" "$NEW_CONTENT" > "$TARGET_FILE.tmp" && mv "$TARGET_FILE.tmp" "$TARGET_FILE"
        ;;
esac

exit 0