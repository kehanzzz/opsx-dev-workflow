# Design Principles

## Workflow First / workflow 优先
OpsX Development Workflow exists to expose every stage—explore, spec, planning, execution, verification, archive, and branch finish—as a deliberate handoff, not as a single prompt or glue layer.

OpsX Development Workflow 的重点，是把探索、规格、计划、执行、验证、归档和分支收尾做成明确交接的阶段，而不是把一切塞进一个 prompt 里。

## Upstream Dependencies Stay External / 上游依赖保持外置
`superpowers:*` comes from <https://github.com/obra/superpowers>, and OpenSpec comes from <https://github.com/Fission-AI/OpenSpec>. This repository only documents how to use them together and does not copy their code.

`superpowers:*` 来自 <https://github.com/obra/superpowers>，OpenSpec 来自 <https://github.com/Fission-AI/OpenSpec>。本仓库只说明如何把它们组合起来使用，不复制它们的代码。

## Documentation First, Scripts Second / 文档优先，脚本其次
Installation guidance is primarily manual, with helper scripts as optional accelerators; host-specific details should live in the docs, not in the scripts.

安装说明应以文档为主，辅助脚本只是加速器；宿主差异要写在文档里，不要藏在脚本里。

## Verification Before Completion / 先验证，再宣告完成
Every install or workflow change includes explicit verification instructions that map to `openspec-verify-change` and `superpowers:test-driven-development`; do not archive or finish a branch until verification artifacts are recorded in `workflow-state/`.

每次安装或工作流变更都要附带明确的验证步骤，对照 `openspec-verify-change` 和 `superpowers:test-driven-development`。在 `workflow-state/` 写入验证材料之前，不要归档，也不要关闭分支。

## Host-aware, Tiered Support / 按宿主分层支持
The workflow targets Codex, Claude Code, Gemini CLI, and opencode, but the public guidance differentiates `Supported`, `Partial`, and `Experimental` statuses so users understand which host paths have been validated.

这个工作流面向 Codex、Claude Code、Gemini CLI 和 opencode，但公开文档会用 `Supported`、`Partial`、`Experimental` 区分成熟度，让用户知道哪些路径已经验证过。 

## Transparent State and Audit / 状态与审计透明
State tracking is not optional—the workflow records entries in `workflow-state/current-workflow-state.md`, `audit-log.md`, and the plan artefacts so reviewers can trace which host, tool, or external execution mode was used in each handoff.

状态追踪不是可选项。每个阶段都要把信息写进 `workflow-state/current-workflow-state.md`、`audit-log.md` 和计划产物里，让审查者能看清每次交接用了哪个宿主、工具和执行方式。 
