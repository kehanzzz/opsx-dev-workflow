# Memory Generation Prompt

## Purpose

在 finalization 阶段生成项目记忆文档。

此 prompt 用于引导 LLM 直接生成 4 个记忆文档：
- `business.md` - 业务背景、核心业务对象、长期成立的业务规则与边界
- `product.md` - 目标用户、核心任务、产品判断原则与关键体验共识
- `architecture.md` - 架构设计与技术决策
- `learnings.md` - 长期复用的失败模式、诊断启发式与交付教训

**重要**：
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

1. 查找包含 `.git` 目录或 `.git` 文件的最近祖先目录
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

同时从 `current-workflow-state.md` 提取对话中沉淀出来的经验信号：

```
- notes
- checkpoint_feedback
- review_feedback
```

---

### Step 3: Generate Documents

#### 3.1 Document: business.md

**目的**：记录长期有效的业务认知，而不是一次性变更摘要

**结构要求**：

```markdown
# 业务介绍

## 业务目标与存在理由
[说明系统存在的根本原因，不要写成单次 feature 目标]

## 核心业务对象
[定义关键术语、对象和它们之间的关系]

## 不可破坏的业务规则
[记录长期成立的业务 invariant、约束和边界]

## 关键业务流程
[仅保留主链路，不写实现细节]

## 成功定义
[记录业务成功信号、代理指标和负向信号]

## 业务边界与非目标
[明确本系统负责和不负责什么]

## 已验证的业务判断
[记录已经被证明有效、可复用的业务结论]

## 更新日志
### {YYYY-MM-DD HH:mm:ss}
- Change ID: {change_id}
- Generated At: {ISO timestamp}
- What Changed in Canonical Understanding: {本次改变了哪些长期业务认知}
```

**生成指令**：
1. 优先提取稳定业务认知: 业务目标、术语、规则、边界、主流程、成功定义
2. 只有当本次变更改变了长期业务认知时，才更新正文对应 section
3. 如果只是实现变化但不改变长期认知，只追加 `## 更新日志`
4. 禁止把一次性任务细节、接口参数或纯技术实现写进正文

---

#### 3.2 Document: product.md

**目的**：记录长期复用的产品判断框架，而不是功能流水账

**结构要求**：

```markdown
# 产品功能

## 目标用户与使用角色
[说明主要用户、次要角色、关键差异]

## 核心任务（JTBD）
[说明用户雇佣产品来完成什么任务]

## 核心场景
[保留 3-5 个高频高价值场景，不写零散功能清单]

## 需求优先级原则
[记录做优先级判断时默认采用的规则]

## 关键体验原则
[记录默认体验要求，如反馈速度、容错、可解释性]

## 关键取舍与拒绝事项
[记录已经拒绝的方案及原因]

## 已知用户坑点
[记录高频误解、失败路径和预防方式]

## 验收与成功信号
[记录 feature 级成功标准和上线后应观察的信号]

## 更新日志
### {YYYY-MM-DD HH:mm:ss}
- Change ID: {change_id}
- Generated At: {ISO timestamp}
- What Changed in Canonical Understanding: {本次改变了哪些长期产品认知}
```

**生成指令**：
1. 优先提取用户、场景、需求判断原则、体验原则和被拒绝方案
2. 只有当本次变更改变了长期产品认知时，才更新正文对应 section
3. 如果只是 feature 实现，没有改变用户模型或产品原则，只追加 `## 更新日志`
4. 禁止把 `Added/Modified/Removed` 清单、负责人栏位或机械功能矩阵当正文主体

---

#### 3.3 Document: architecture.md

**目的**：记录长期复用的架构认知与决策约束，而不是单次技术变更清单

**结构要求**：

```markdown
# 架构文档

## 系统目标与架构边界
[说明系统在技术层面必须长期满足什么，以及明确的职责边界]

## 核心组件与职责
[定义关键模块、接口责任和依赖边界]

## 关键数据流与控制流
[只保留主调用链、状态变化和失败路径，不写零散实现细节]

## 关键技术决策
[记录关键决策、备选方案、权衡和未来重评估触发条件]

## 依赖与外部系统
[记录关键依赖、集成边界和耦合风险]

## 扩展点与演进策略
[记录扩展点、演进限制和重构信号]

## 运行与操作约束
[记录运行假设、观测点、故障定位入口和关键操作注意事项]

## 已验证的架构判断
[记录已经被性能、事故、测试或生产观察验证过的架构结论]

## 更新日志
### {YYYY-MM-DD HH:mm:ss}
- Change ID: {change_id}
- Generated At: {ISO timestamp}
- What Changed in Canonical Understanding: {本次改变了哪些长期架构认知}
```

**生成指令**：
1. 优先提取系统边界、核心组件职责、主调用链、关键技术决策、演进约束和运维观测点
2. 只有当本次变更改变了长期架构认知时，才更新正文对应 section
3. 如果只是实现或局部接口变化，没有改变长期架构认知，只追加 `## 更新日志`
4. 禁止把单次 API 变更、零散依赖列表或部署流水账当作正文主体

---

#### 3.4 Document: learnings.md

**目的**：记录长期复用的失败模式、诊断启发式与交付教训，而不是一次性踩坑流水账

**结构要求**：

```markdown
# 项目经验与教训

## 高价值失败模式
### {模式名称}
- 适用范围: {通常在哪类任务、模块或阶段出现}
- 触发信号: {遇到什么现象时应联想到这个模式}
- 常见误判: {最容易做出的错误判断}
- 实际根因: {真正的深层原因}
- 首选排查路径: {优先检查的证据、文件或命令}
- 标准修复策略: {已验证有效的修复方式}
- 预防规则: {以后如何避免再次发生}

## 调试与诊断启发式
[沉淀可复用的排查顺序、证据优先级和反例]

## 关键决策教训
[记录高成本错误决策、代价和未来默认做法]

## Review 与交接检查清单
[记录进入 code review、验证或交接前必须确认的检查项]

## 已验证的有效实践
[记录已经多次证明有效的工作方式及复用边界]

## 更新日志
### {YYYY-MM-DD HH:mm:ss}
- Change ID: {change_id}
- Generated At: {ISO timestamp}
- What Changed in Canonical Understanding: {本次新增或修正了哪些长期有效的经验教训}
```

**生成指令**：
1. 优先从 audit-log.md、current-plan.md、git diff，以及 workflow-state 中的 `notes` / `checkpoint_feedback` / `review_feedback` 抽取可复用的失败模式、诊断路径和预防规则
2. 只有当本次变更改变了长期经验认知时，才更新正文对应 section
3. 如果只是一次性实现问题或局部修复，没有形成可复用教训，只追加 `## 更新日志`
4. 禁止把逐日流水账、耗时记录、零散 bug 列表或临时情绪化结论写成正文

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
| 文档存在且有变更 | 优先按同名 canonical section 合并正文，并将最新记录插入日志 section 顶部 |
| 文档存在但无相关变更 | 跳过，保持原样 |

#### 4.3 合并操作

对于已存在的文档，使用 `skill/scripts/merge-document.sh --mode=smart`：

- 如果目标文档和新内容都包含 `##` 顶级 section：
  - 同名正文 section 以新内容为准
  - 目标文档缺失但新内容存在的 section 自动补入
  - 对 `business.md`、`product.md`、`architecture.md`、`learnings.md` 按对应模板顺序输出正文
  - `## 更新日志` 或 `## 变更历史` 单独合并，新记录插到顶部
- 如果新内容只是纯文本片段：
  - 保持旧行为，只把片段插入日志 section 顶部

```markdown
## 变更历史

### {YYYY-MM-DD HH:mm:ss}
- Change ID: {change_id}
- Generated At: {ISO timestamp}
[生成的新内容]
```

**注意**：
- 不删除已有内容
- 保持原有结构
- 对 structured memory 文档优先做 section-aware merge，而不是整段覆盖
- 对已知 memory 文档按模板定义的 canonical section 顺序输出正文
- 新记录插入到 `## 变更历史` 标题下方
- 如果文档还没有 `## 变更历史`，在文档末尾追加该 section
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
FILE_COUNT=$(git diff $MAIN_BRANCH...HEAD --name-only | sed '/^[[:space:]]*$/d' | wc -l)

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "SKIP: No changes detected"
    exit 0
fi
```

#### 6.2 处理方式

空变更时：

```
1. 输出信息：Skipping memory generation - no changes detected
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

### 更新记录元数据

每个新增的变更记录必须包含：

```markdown
- Change ID: {change_id}
- Generated At: {ISO timestamp}
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
