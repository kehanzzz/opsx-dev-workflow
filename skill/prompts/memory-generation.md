# Memory Generation Prompt

## Purpose

在 Phase 8 (Finish Branch Development) 阶段生成项目记忆文档。

此 prompt 用于引导 LLM 直接生成 4 个记忆文档：
- `business.md` - 业务背景与目标
- `product.md` - 产品需求与变更
- `architecture.md` - 架构设计与技术决策
- `learnings.md` - 踩坑经验与教训

**重要**：
- 不使用 subagent
- 不记录敏感信息（密钥、凭证等）
- 失败时跳过并警告
- 空变更时跳过生成

---

## Input Sources

### 1. Workflow State

路径：`{PROJECT_ROOT}/openspec/changes/{CHANGE_ID}/workflow-state/`

需要读取的文件：

| 文件 | 用途 |
|------|------|
| `current-workflow-state.md` | 当前工作流状态 |
| `audit-log.md` | 审计日志 |
| `current-plan.md` | 执行计划 |
| `delta-spec.md` | 变更规格说明 |

### 2. Git Diff

获取当前分支与主分支的差异：

```bash
# 获取分支名
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# 获取主分支名 (main 或 master)
MAIN_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|origin/||')
[ -z "$MAIN_BRANCH" ] && MAIN_BRANCH="main"

# 获取 diff
git diff $MAIN_BRANCH...HEAD --stat
git diff $MAIN_BRANCH...HEAD --name-only
```

### 3. Project Root Detection

用户项目根目录通过以下方式确定：

1. 查找包含 `.git` 目录的最近祖先目录
2. 或者使用 `skill/scripts/get-project-root.sh` 脚本
3. 目标 docs 目录：`{PROJECT_ROOT}/docs/`

---

## Generation Process

### Step 1: Gather Context

#### 1.1 读取 Workflow State

按以下顺序读取文件：

```
1. current-workflow-state.md
   - 提取: phase, change_id, status, timestamp
   
2. audit-log.md
   - 提取: 关键决策点, 变更历史
   
3. current-plan.md
   - 提取: 已完成任务, 待办任务, 执行摘要
   
4. delta-spec.md (如果存在)
   - 提取: 变更描述, 涉及文件, 需求来源
```

#### 1.2 验证变更存在

```bash
# 检查是否有实际代码变更
FILE_COUNT=$(git diff $MAIN_BRANCH...HEAD --name-only | wc -l)

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "SKIP: No code changes detected"
    exit 0
fi
```

---

### Step 2: Analyze Changes

#### 2.1 文件变更分析

提取以下信息：

| 维度 | 分析内容 |
|------|----------|
| 文件类型 | 配置文件 / 源代码 / 测试文件 / 文档 |
| 涉及模块 | 前端 / 后端 / 基础设施 / 文档 |
| 变更规模 | 新增 / 修改 / 删除文件数 |
| 关联性 | 是否跨模块、跨技术栈 |

#### 2.2 关键变更识别

从 diff 中提取：

```
- 新增功能点
- 删除的代码及原因
- 修改的逻辑及影响
- 配置变更
- 依赖变更
```

#### 2.3 决策点提取

从 audit-log.md 提取：

```
- 技术选型决策
- 设计模式选择
- 权衡取舍点
- 已知限制
```

---

### Step 3: Generate Documents

#### 3.1 Document: business.md

**目的**：记录业务背景与目标

**结构要求**：

```markdown
# Business Context

## Change Overview
- Change ID: {change_id}
- Date: {timestamp}
- Branch: {branch_name}

## Business Goal
[简要说明此次变更的业务目标]

## Background
[变更前的业务状态]

## Impact
[变更带来的业务影响]

## Success Criteria
[如何衡量变更成功]

## Related Links
- [相关 Issue/PR 链接]
```

**生成指令**：
1. 从 delta-spec.md 提取业务目标
2. 从 current-workflow-state.md 提取变更时间
3. 从 git diff 提取涉及的配置文件
4. 组织为业务视角的描述

---

#### 3.2 Document: product.md

**目的**：记录产品需求与变更

**结构要求**：

```markdown
# Product Requirements

## Change Overview
- Change ID: {change_id}
- Date: {timestamp}

## Requirements Addressed
[此次变更解决的问题列表]

## Feature Changes
### Added
- [新增功能描述]

### Modified
- [修改功能描述]

### Removed
- [删除功能描述]

## User Impact
[对用户的影响]

## Success Metrics
[成功指标]
```

**生成指令**：
1. 从 delta-spec.md 提取需求描述
2. 从 git diff 提取新增/修改的功能点
3. 从 audit-log.md 提取产品决策
4. 组织为产品视角的描述

---

#### 3.3 Document: architecture.md

**目的**：记录架构设计与技术决策

**结构要求**：

```markdown
# Architecture & Technical Decisions

## Change Overview
- Change ID: {change_id}
- Date: {timestamp}

## Technical Decisions
### Decision 1: {标题}
- Context: {决策背景}
- Decision: {决策内容}
- Alternatives Considered: {备选方案}
- Trade-offs: {权衡点}

## Architecture Changes
[架构层面的变更描述]

## Dependencies
### New Dependencies
- [新增依赖]

### Modified Dependencies
- [修改的依赖]

## Data Models
[数据模型变更，如果有]

## API Changes
[API 变更，如果有]
```

**生成指令**：
1. 从 audit-log.md 提取技术决策
2. 从 git diff 提取依赖变更
3. 从代码变更中提取架构影响
4. 组织为技术视角的描述

---

#### 3.4 Document: learnings.md

**目的**：记录踩坑经验与教训

**结构要求**：

```markdown
# Learnings & Lessons

## Change Overview
- Change ID: {change_id}
- Date: {timestamp}

## Challenges Faced
### Challenge 1: {标题}
- Problem: {问题描述}
- Root Cause: {根本原因}
- Solution: {解决方案}
- Duration: {解决问题花费的时间}

## Unexpected Issues
[开发过程中遇到的意外问题]

## Knowledge Gained
[新获得的知识]

## Recommendations
[对未来类似工作的建议]

## References
[相关文档、链接]
```

**生成指令**：
1. 从 audit-log.md 提取问题与解决方案
2. 从 git diff 提取修复的 bug
3. 从 current-plan.md 提取执行过程中的挑战
4. 组织为经验视角的描述

---

### Step 4: Smart Merge

#### 4.1 检测现有文档

```bash
DOCS_DIR="{PROJECT_ROOT}/docs"
TARGET_FILES=("business.md" "product.md" "architecture.md" "learnings.md")

for file in "${TARGET_FILES[@]}"; do
    if [ -f "$DOCS_DIR/$file" ]; then
        echo "EXISTS: $file"
    else
        echo "NEW: $file"
    fi
done
```

#### 4.2 合并策略

| 场景 | 策略 |
|------|------|
| 文档不存在 | 直接创建 |
| 文档存在且有变更 | 追加到变更历史 section |
| 文档存在但无相关变更 | 跳过，保持原样 |

#### 4.3 合并操作

对于已存在的文档：

```markdown
---
## {YYYY-MM-DD} Update (Change: {change_id})

[生成的新内容]

---
*Previous content preserved above*
```

**注意**：
- 不删除已有内容
- 保持原有结构
- 新内容追加到顶部
- 添加时间戳和 change ID

---

### Step 5: Error Handling

#### 5.1 常见错误及处理

| 错误场景 | 处理方式 |
|----------|----------|
| 项目根目录未找到 | 警告并跳过，记录日志 |
| docs 目录无法创建 | 警告并跳过，记录日志 |
| Git 操作失败 | 警告并跳过，记录日志 |
| 文件写入失败 | 警告并跳过，记录日志 |
| LLM 生成失败 | 返回原始 prompt 状态 |

#### 5.2 日志记录

所有警告记录到日志：

```bash
LOG_FILE="{PROJECT_ROOT}/.opsx/memory-generation.log"

log_warning() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1" >> "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
}
```

#### 5.3 失败策略

```
1. 如果任何关键步骤失败：
   - 记录警告日志
   - 跳过当前文档生成
   - 继续处理其他文档
   
2. 如果全部失败：
   - 输出总体警告信息
   - 不阻塞主流程
   
3. 返回状态：
   - 成功: 生成了 1-4 个文档
   - 跳过: 无变更或处理失败
   - 警告: 部分失败但不影响流程
```

---

### Step 6: Empty Change Handling

#### 6.1 检测空变更

```bash
# 无文件变更
FILE_COUNT=$(git diff $MAIN_BRANCH...HEAD --name-only | wc -l)

# 无实质内容变更（只包含文档注释等）
CONTENT_CHANGE=$(git diff $MAIN_BRANCH...HEAD --stat | grep -E "^\s+[0-9]+.*\.md$")

if [ "$FILE_COUNT" -eq 0 ] || [ -z "$CONTENT_CHANGE" ]; then
    echo "SKIP: No significant changes"
    exit 0
fi
```

#### 6.2 处理方式

空变更时：

```
1. 输出信息：Skipping memory generation - no significant changes
2. 不创建/更新任何文档
3. 不记录日志（避免日志膨胀）
4. 正常返回主流程
```

---

## Output Format Requirements

### 文件位置

```
{PROJECT_ROOT}/docs/
├── business.md
├── product.md
├── architecture.md
└── learnings.md
```

### 格式规范

| 规范项 | 要求 |
|--------|------|
| 文件格式 | UTF-8 编码的 Markdown |
| 章节标题 | 使用 ATX 风格 (# ## ###) |
| 列表格式 | 使用 - 或 1. 风格 |
| 代码块 | 使用 triple backticks |
| 链接格式 | [text](url) 风格 |
| 图片格式 | 不包含（纯文本文档） |

### 元数据

每个文档必须包含：

```markdown
---
change_id: {change_id}
generated_at: {ISO timestamp}
---
```

---

## Execution Summary

执行流程摘要：

```
1. [CHECK] 验证有实际代码变更 → 无则跳过
2. [READ] 读取 workflow-state 文件
3. [ANALYZE] 分析 git diff 提取关键信息
4. [GENERATE] 为每个文档生成内容
5. [MERGE] 智能合并到现有文档
6. [LOG] 记录操作结果
7. [REPORT] 报告生成状态
```

成功标准：

- ✅ 至少生成 1 个文档
- ✅ 文档格式符合规范
- ✅ 智能合并保留历史内容
- ✅ 错误不阻塞主流程

---

## Appendix: Quick Reference

### 文件路径速查

| 变量 | 路径 |
|------|------|
| PROJECT_ROOT | 用户项目根目录 |
| CHANGE_ID | 当前变更 ID |
| DOCS_DIR | {PROJECT_ROOT}/docs |
| WORKFLOW_STATE | {PROJECT_ROOT}/openspec/changes/{CHANGE_ID}/workflow-state |

### 命令速查

```bash
# 检测空变更
git diff main...HEAD --name-only | wc -l

# 读取 workflow state
cat {WORKFLOW_STATE}/current-workflow-state.md

# 写入文档
echo "$CONTENT" >> {DOCS_DIR}/{document}.md
```

### 错误代码

| 代码 | 含义 |
|------|------|
| 0 | 成功 |
| 1 | 无变更跳过 |
| 2 | 项目根目录未找到 |
| 3 | Git 操作失败 |
| 4 | 文件写入失败 |