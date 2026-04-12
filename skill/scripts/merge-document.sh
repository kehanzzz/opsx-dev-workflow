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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
                  - 对 structured 文档按同名 section 合并正文
                  - 对已知记忆文档按模板顺序输出正文 section
                  - 将新的变更记录插入到日志标题下方
                  - 如果没有日志部分，则在文档末尾追加

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
    local target_tmp content_tmp merged_tmp template_tmp
    local target_basename template_file

    if [ ! -f "$target" ]; then
        echo "$content"
        return 0
    fi

    cleanup_smart_merge() {
        rm -f "$target_tmp" "$content_tmp" "$merged_tmp"
        if [ -n "$template_tmp" ] && [ "$template_tmp" != "/dev/null" ]; then
            rm -f "$template_tmp"
        fi
    }

    target_tmp="$(mktemp)"
    content_tmp="$(mktemp)"
    merged_tmp="$(mktemp)"
    template_tmp=""

    printf '%s\n' "$content" > "$content_tmp"
    cp "$target" "$target_tmp"

    target_basename="$(basename "$target")"
    template_file="$SCRIPT_DIR/../assets/document-templates/$target_basename"
    if [ -f "$template_file" ]; then
        template_tmp="$(mktemp)"
        cp "$template_file" "$template_tmp"
    else
        template_tmp="/dev/null"
    fi

    if rg -q "^##[[:space:]]+" "$target_tmp" && rg -q "^##[[:space:]]+" "$content_tmp"; then
        if awk '
            function trim(text) {
                sub(/^[[:space:]]+/, "", text)
                sub(/[[:space:]]+$/, "", text)
                return text
            }
            function is_log_header(line) {
                return line == "## 更新日志" || line == "## 变更历史"
            }
            function append_line(block, line) {
                return block ? block ORS line : line
            }
            function flush_section(kind,    header_key) {
                if (current_header == "") {
                    return
                }
                header_key = current_header
                if (kind == "content") {
                    content_sections[header_key] = current_block
                    content_order[++content_count] = header_key
                    if (is_log_header(header_key)) {
                        content_log_header = header_key
                    }
                } else if (kind == "template") {
                    if (!is_log_header(header_key)) {
                        template_order[++template_count] = header_key
                    }
                } else {
                    target_sections[header_key] = current_block
                    target_order[++target_count] = header_key
                    if (is_log_header(header_key)) {
                        target_log_header = header_key
                    }
                }
                current_header = ""
                current_block = ""
            }
            FNR == 1 {
                flush_section(kind)
                current_header = ""
                current_block = ""
            }
            FILENAME == ARGV[1] {
                kind = "content"
            }
            FILENAME == ARGV[2] {
                kind = "target"
            }
            FILENAME == ARGV[3] {
                kind = "template"
            }
            /^##[[:space:]]+/ {
                flush_section(kind)
                current_header = $0
                current_block = $0
                next
            }
            {
                if (current_header == "") {
                    if (kind == "content") {
                        content_prelude = append_line(content_prelude, $0)
                    } else {
                        target_prelude = append_line(target_prelude, $0)
                    }
                } else {
                    current_block = append_line(current_block, $0)
                }
            }
            END {
                flush_section(kind)

                log_header = target_log_header ? target_log_header : content_log_header
                if (log_header == "") {
                    log_header = "## 更新日志"
                }

                prelude = target_prelude ? target_prelude : content_prelude
                if (prelude != "") {
                    print prelude
                }

                if (template_count > 0) {
                    for (i = 1; i <= template_count; i++) {
                        header = template_order[i]
                        if (header in content_sections) {
                            print ""
                            print content_sections[header]
                            used_content[header] = 1
                            used_target[header] = 1
                        } else if (header in target_sections) {
                            print ""
                            print target_sections[header]
                            used_target[header] = 1
                        }
                    }
                }

                for (i = 1; i <= target_count; i++) {
                    header = target_order[i]
                    if (is_log_header(header) || (header in used_target)) {
                        continue
                    }
                    if (header in content_sections) {
                        print ""
                        print content_sections[header]
                        used_content[header] = 1
                        used_target[header] = 1
                    } else {
                        print ""
                        print target_sections[header]
                    }
                }

                for (i = 1; i <= content_count; i++) {
                    header = content_order[i]
                    if (is_log_header(header) || (header in used_content)) {
                        continue
                    }
                    print ""
                    print content_sections[header]
                    inserted_new_sections = 1
                }

                print ""
                print log_header

                if (content_log_header != "" && content_sections[content_log_header] != "") {
                    split(content_sections[content_log_header], lines, /\n/)
                    for (i = 2; i <= length(lines); i++) {
                        line = lines[i]
                        if (trim(line) == "" && pending_blank == 0) {
                            pending_blank = 1
                            continue
                        }
                        if (trim(line) != "") {
                            if (pending_blank == 1) {
                                print ""
                                pending_blank = 0
                            }
                            print line
                            content_log_printed = 1
                        }
                    }
                    pending_blank = 0
                }

                if (target_log_header != "" && target_sections[target_log_header] != "") {
                    split(target_sections[target_log_header], lines, /\n/)
                    for (i = 2; i <= length(lines); i++) {
                        line = lines[i]
                        if (trim(line) == "" && target_pending_blank == 0) {
                            target_pending_blank = 1
                            continue
                        }
                        if (trim(line) != "") {
                            if (content_log_printed || target_log_printed || target_pending_blank == 1) {
                                print ""
                            }
                            print line
                            target_log_printed = 1
                            target_pending_blank = 0
                        }
                    }
                }
            }
        ' "$content_tmp" "$target_tmp" "$template_tmp" > "$merged_tmp"; then
            cat "$merged_tmp"
            cleanup_smart_merge
            return 0
        fi
    fi

    local timestamp
    timestamp="$(date "+%Y-%m-%d %H:%M:%S")"

    if rg -qi "^##[[:space:]].*变更" "$target"; then
        awk -v timestamp="$timestamp" -v content="$content" '
            BEGIN {
                inserted = 0
            }
            {
                print
                if (!inserted && $0 ~ /^##[[:space:]].*变更/) {
                    print ""
                    print "### " timestamp
                    print content
                    print ""
                    inserted = 1
                }
            }
        ' "$target"
    else
        cat "$target"
        echo ""
        echo "## 变更历史"
        echo ""
        echo "### $timestamp"
        echo "$content"
    fi

    cleanup_smart_merge
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
