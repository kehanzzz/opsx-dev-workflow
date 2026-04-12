#!/bin/bash

# 用法: get-project-root.sh
# 说明: 从当前工作目录向上查找项目根目录（包含 .git 目录或 .git 文件的目录）
# 输出: 项目根目录的绝对路径
# 退出码: 0 成功，1 未找到

show_help() {
    cat << 'EOF'
获取项目根目录脚本

用法:
    get-project-root.sh

说明:
    从当前工作目录向上递归查找包含 .git 目录或 .git 文件的目录
    即为项目根目录

输出:
    项目根目录的绝对路径

退出码:
    0 - 成功找到项目根目录
    1 - 未找到项目根目录（当前目录不是 Git 仓库的一部分）

示例:
    cd /path/to/project/subdir
    ./get-project-root.sh
    # 输出: /path/to/project
EOF
}

# 显示帮助
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# 获取起始目录（默认为当前目录）
START_DIR="${1:-$PWD}"

# 转换为绝对路径
if ! CURRENT_DIR="$(cd "$START_DIR" 2>/dev/null && pwd)"; then
    echo "错误: 无法访问目录: $START_DIR" >&2
    exit 1
fi

# 向上查找包含 .git 目录或 .git 文件的目录
while [ "$CURRENT_DIR" != "/" ]; do
    if [ -d "$CURRENT_DIR/.git" ] || [ -f "$CURRENT_DIR/.git" ]; then
        echo "$CURRENT_DIR"
        exit 0
    fi
    CURRENT_DIR="$(dirname "$CURRENT_DIR")"
done

# 检查根目录
if [ -d "/.git" ] || [ -f "/.git" ]; then
    echo "/"
    exit 0
fi

echo "错误: 未找到项目根目录（.git 目录或文件）" >&2
exit 1
