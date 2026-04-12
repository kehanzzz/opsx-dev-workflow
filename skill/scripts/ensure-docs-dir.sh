#!/bin/bash

# 用法: ensure-docs-dir.sh [project-root]
# 说明: 确保用户项目的 docs 目录存在
# 参数: 可选的项目根目录路径（默认使用 get-project-root.sh 自动检测）
# 输出: docs 目录的绝对路径
# 退出码: 0 成功，1 失败

show_help() {
    cat << 'EOF'
确保 docs 目录存在脚本

用法:
    ensure-docs-dir.sh [project-root]

参数:
    project-root  可选的项目根目录路径
                  如果省略，将自动从当前目录向上查找

输出:
    docs 目录的绝对路径

退出码:
    0 - 成功（docs 目录已存在或已创建）
    1 - 失败（无法确定项目根目录或创建目录失败）

示例:
    ./ensure-docs-dir.sh
    ./ensure-docs-dir.sh /path/to/project
EOF
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

PROJECT_ROOT="${1:-}"

if [ -z "$PROJECT_ROOT" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$("$SCRIPT_DIR/get-project-root.sh")" || {
        echo "错误: 无法确定项目根目录" >&2
        exit 1
    }
fi

if [ ! -d "$PROJECT_ROOT" ]; then
    echo "错误: 目录不存在: $PROJECT_ROOT" >&2
    exit 1
fi

DOCS_DIR="$PROJECT_ROOT/docs"

if [ ! -d "$DOCS_DIR" ]; then
    if ! mkdir -p "$DOCS_DIR" 2>/dev/null; then
        echo "错误: 无法创建 docs 目录: $DOCS_DIR" >&2
        exit 1
    fi
fi

echo "$DOCS_DIR"
exit 0