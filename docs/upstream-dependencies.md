# Upstream Dependencies / 上游依赖

OpsX Development Workflow orchestrates upstream skills without vendorizing their implementations. The documentation below names the required, recommended, and optional dependencies along with their source-of-truth repositories.

OpsX 研发工作流依赖上游能力，但不会把它们的实现拷贝进来。下面列出必需、推荐和可选依赖，以及各自的来源仓库。

## Current Integration Baseline / 当前集成基线

- `superpowers`: <https://github.com/obra/superpowers> — the source for `superpowers:*` workflow and execution helpers.
- `OpenSpec`: <https://github.com/Fission-AI/OpenSpec> — the source for the current `openspec-*` skills and the underlying `openspec` CLI.

当前集成基线依赖这两个仓库：

- `superpowers`：<https://github.com/obra/superpowers>，提供 `superpowers:*` 工作流与执行辅助
- `OpenSpec`：<https://github.com/Fission-AI/OpenSpec>，提供当前 `openspec-*` skills 以及底层 `openspec` CLI

These mappings describe the current repository-level expectations. Update the tables before each release if the upstream behavior or availability changes.

下表描述的是当前仓库层面的预期状态。若上游行为或可用性变化，发布前应同步更新。

## Required Dependencies / 必需依赖

| Dependency | Upstream Repository | Role in Workflow | Level | Tested Baseline | Notes |
| --- | --- | --- | --- | --- | --- |
| `openspec-propose` | <https://github.com/Fission-AI/OpenSpec> | Creates the change and the initial proposal/design/tasks artifact set. | Required | Repository-level baseline | Primary OpenSpec entry point for this workflow. |
| `openspec-verify-change` | <https://github.com/Fission-AI/OpenSpec> | Enforces the implementation/spec coherence gate before archive. | Required | Repository-level baseline | Run after repository verification and before archive. |
| `openspec-archive-change` | <https://github.com/Fission-AI/OpenSpec> | Finalizes the change archive and closes the OpenSpec loop. | Required | Repository-level baseline | Final OpenSpec gate before branch finish. |

中文说明：

- `openspec-propose`：生成 change 及首批 proposal/design/tasks 产物
- `openspec-verify-change`：在归档前校验实现与变更产物是否一致
- `openspec-archive-change`：完成最终归档并关闭 OpenSpec 流程

## Recommended Dependencies / 推荐依赖

| Dependency | Upstream Repository | Role in Workflow | Level | Tested Baseline | Notes |
| --- | --- | --- | --- | --- | --- |
| `writing-plans` | <https://github.com/obra/superpowers> | Produces executable plans aligned with the spec. | Recommended | Repository-level baseline | Part of the standard plan → execution handoff. |
| `finishing-a-development-branch` | <https://github.com/obra/superpowers> | Closes the change with explicit merge/PR decisions. | Recommended | Repository-level baseline | Final guardrail after verification. |
| `test-driven-development` | <https://github.com/obra/superpowers> | Ensures implementation follows discipline. | Recommended | Repository-level baseline | Reference for every execution task. |
| `subagent-driven-development` | <https://github.com/obra/superpowers> | Preferred execution mode when subagents are available. | Recommended | Repository-level baseline | Enables parallel work within the change. |
| `openspec-explore` | <https://github.com/Fission-AI/OpenSpec> | Keeps requirement exploration inside the same OpenSpec mental model before proposal. | Recommended | Repository-level baseline | Useful when the session starts with problem framing rather than implementation. |

中文说明：

- `writing-plans`：生成与 spec 对齐的可执行计划
- `finishing-a-development-branch`：做最终分支收尾
- `test-driven-development`：约束实现纪律
- `subagent-driven-development`：在可用时优先用于执行
- `openspec-explore`：在进入 proposal 前，用同一套 OpenSpec 语境做探索

## Optional Paths / 可选路径

| Dependency | Upstream Repository | Role in Workflow | Level | Tested Baseline | Notes |
| --- | --- | --- | --- | --- | --- |
| `openspec-new-change` | <https://github.com/Fission-AI/OpenSpec> | Starts a change with the artifact-first experimental path. | Optional | Repository-level baseline | Use only when you want the experimental OpenSpec artifact workflow. |
| `openspec-continue-change` | <https://github.com/Fission-AI/OpenSpec> | Continues an existing change and advances artifact work. | Optional | Repository-level baseline | Helpful for resuming partially complete OpenSpec changes. |
| `openspec-ff-change` | <https://github.com/Fission-AI/OpenSpec> | Fast-forwards artifact generation in the experimental path. | Optional | Repository-level baseline | Host support may vary. |
| `openspec-apply-change` | <https://github.com/Fission-AI/OpenSpec> | Standard OpenSpec implementation handoff. | Optional | Repository-level baseline | This workflow often uses its own step-5 execution path instead. |
| `openspec-sync-specs` | <https://github.com/Fission-AI/OpenSpec> | Syncs delta specs back into the main spec set before or during archive. | Optional | Repository-level baseline | Useful in repos that keep long-lived OpenSpec spec trees. |

中文说明：

- `openspec-new-change`：实验性的 change 初始化路径
- `openspec-continue-change`：继续推进已有 change
- `openspec-ff-change`：在实验路径中加速产物推进
- `openspec-apply-change`：标准实现交接入口
- `openspec-sync-specs`：把 delta specs 同步回主 specs

## Versioning Notes / 版本说明

We track the baseline at the repository level and do not pin specific tags or commits. Before public releases, revisit both upstream repositories to confirm the workflows (`superpowers:*` and the current `openspec-*` skills) still behave as expected.

我们以仓库级别追踪基线，不锁定具体 tag 或 commit。每次发布前，都要重新确认 `superpowers:*` 和当前 `openspec-*` skills 仍然符合预期。
