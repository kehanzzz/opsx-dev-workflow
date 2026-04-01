# Workflow Overview

OpsX Development Workflow ties discovery, specification, planning, execution, verification, archive, and branch finish into a single, auditable narrative so multi-agent sessions never leave important decisions only in chat history.

OpsX 研发工作流把探索、规格、计划、实现、验证、归档与分支收尾串成一条可审计的链路，避免多 agent 会话只把关键决策留在聊天记录里。

Every stage records its outputs inside the change's `workflow-state/` directory (`current-workflow-state.md`, `audit-log.md`) so future agents, reviewers, and hosts can rehydrate context from concrete files.

每个阶段都把结果写进 change 下的 `workflow-state/` 目录，例如 `current-workflow-state.md` 和 `audit-log.md`，方便后续 agent、审查者和宿主恢复上下文。

## Stage 1: Explore / 阶段 1：探索
Requirement exploration happens before implementation and should be captured into the proposal/spec path rather than left only in chat history. `openspec-explore` is the most direct OpenSpec entry for this stage.

需求探索应发生在实现之前，并写进 proposal/spec 路径，而不是只留在聊天记录中。这个阶段最直接的 OpenSpec 入口是 `openspec-explore`。

## Stage 2: Branch Setup / 阶段 2：分支准备
Establish a dedicated branch or use `superpowers:using-git-worktrees` to isolate the change before touching spec, plan, or code so the workspace stays clean.

在写 spec、计划或代码之前，先切出专属分支，或用 `superpowers:using-git-worktrees` 做隔离，避免污染工作区。

## Stage 3: Change and Spec Creation / 阶段 3：创建 Change 与 Spec
Create the change through `openspec-propose` and document the scope in the spec before writing the plan. If your host exposes the experimental artifact-first path, `openspec-new-change` is an optional compatibility route.

优先使用 `openspec-propose` 创建 change，并先把范围写进 spec，再开始写计划。若宿主暴露了实验性的 artifact-first 路径，也可以把 `openspec-new-change` 作为兼容方案。

## Stage 4: Planning / 阶段 4：计划
`superpowers:writing-plans` turns the spec into actionable tasks with clear dependencies, reviewers, and success criteria; each task references the spec and its verification steps.

`superpowers:writing-plans` 会把 spec 拆成可执行任务，明确依赖、审查点和成功标准；每个任务都应指回 spec 和验证步骤。

## Stage 5: Execution / 阶段 5：执行
Implementation follows `superpowers:test-driven-development`. Prefer `superpowers:subagent-driven-development`; if an external agent or helper is needed, write the chosen execution mode (efficiency vs. quality) into the workflow state.

执行阶段遵循 `superpowers:test-driven-development`，优先使用 `superpowers:subagent-driven-development`。如果需要外部 agent 或辅助工具，要把选定的执行模式写进 workflow state。  

## Stage 6: Verification / 阶段 6：验证
Verification combines repository-specific checks with `openspec-verify-change` so the change is both technically verified and structurally valid before archive. Any failing check reopens the relevant previous stage and stays logged in the audit trail.

验证阶段要同时做仓库级检查和 `openspec-verify-change`。这样在归档前，变更既通过技术验证，也通过结构校验。任何失败都应回退到前一阶段，并写进审计记录。

## Stage 7: Archive / 阶段 7：归档
Use `openspec-archive-change` as the standard archive path. Archiving should only happen after implementation and validation are complete.

标准归档路径是 `openspec-archive-change`。只有在实现和验证都完成后才应归档。

## Stage 8: Branch Finish / 阶段 8：分支收尾
`superpowers:finishing-a-development-branch` closes out the branch, decides between merge, PR, or manual handoff, and leaves a final note about what was verified.

`superpowers:finishing-a-development-branch` 负责最后的分支收尾，决定是合并、发 PR，还是人工交接，并留下最终验证说明。

### State and Audit Tracking / 状态与审计
Each stage writes `workflow-state/current-workflow-state.md`, `workflow-state/audit-log.md`, and any execution notes so reviewers never have to guess which host or tool was used.

每个阶段都应写入 `workflow-state/current-workflow-state.md`、`workflow-state/audit-log.md` 和必要的执行备注，避免审查者靠猜测判断用了哪个宿主或工具。

Upstream references: https://github.com/obra/superpowers, https://github.com/Fission-AI/OpenSpec; this repository documents how to orchestrate those toolkits without vendorizing their source code.

上游仓库是 https://github.com/obra/superpowers 和 https://github.com/Fission-AI/OpenSpec；本仓库只记录如何把它们组合起来使用，不包含它们的源码。
