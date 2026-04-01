# 工作流概览

OpsX 研发工作流把探索、规格、计划、实现、验证、归档与分支收尾串成一条可审计的链路，避免多 agent 会话只把关键决策留在聊天记录里。

每个阶段都把结果写进 change 下的 `workflow-state/` 目录，例如 `current-workflow-state.md` 和 `audit-log.md`，方便后续 agent、审查者和宿主恢复上下文。

## 阶段 1：探索

需求探索应发生在实现之前，并写进 proposal 或 spec 路径，而不是只留在聊天记录中。这个阶段最直接的 OpenSpec 入口是 `openspec-explore`。

## 阶段 2：分支准备

在写 spec、计划或代码之前，先切出专属分支，或用 `superpowers:using-git-worktrees` 做隔离，避免污染工作区。

## 阶段 3：创建 Change 与 Spec

优先使用 `openspec-propose` 创建 change，并先把范围写进 spec，再开始写计划。若宿主暴露了实验性的 artifact-first 路径，也可以把 `openspec-new-change` 作为兼容方案。

## 阶段 4：计划

`superpowers:writing-plans` 会把 spec 拆成可执行任务，明确依赖、审查点和成功标准。每个任务都应指回 spec 和验证步骤。

## 阶段 5：执行

执行阶段遵循 `superpowers:test-driven-development`，优先使用 `superpowers:subagent-driven-development`。如果需要外部 agent 或辅助工具，要把选定的执行模式写进 workflow state。

## 阶段 6：验证

验证阶段要同时做仓库级检查和 `openspec-verify-change`。这样在归档前，变更既通过技术验证，也通过结构校验。任何失败都应回退到前一阶段，并写进审计记录。

## 阶段 7：归档

标准归档路径是 `openspec-archive-change`。只有在实现和验证都完成后才应归档。

## 阶段 8：分支收尾

`superpowers:finishing-a-development-branch` 负责最后的分支收尾，决定是合并、发 PR，还是人工交接，并留下最终验证说明。

### 状态与审计

每个阶段都应写入 `workflow-state/current-workflow-state.md`、`workflow-state/audit-log.md` 和必要的执行备注，避免审查者靠猜测判断用了哪个宿主或工具。

上游仓库是 <https://github.com/obra/superpowers> 和 <https://github.com/Fission-AI/OpenSpec>；本仓库只记录如何把它们组合起来使用，不包含它们的源码。
