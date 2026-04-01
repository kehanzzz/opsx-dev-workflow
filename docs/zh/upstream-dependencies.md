# 上游依赖

OpsX Development Workflow 依赖上游能力，但不会把它们的实现拷贝进来。下面列出必需、推荐和可选依赖，以及各自的来源仓库。

## 当前集成基线

- `superpowers`：<https://github.com/obra/superpowers>，提供 `superpowers:*` 工作流与执行辅助
- `OpenSpec`：<https://github.com/Fission-AI/OpenSpec>，提供当前 `openspec-*` skills 以及底层 `openspec` CLI

下表描述的是当前仓库层面的预期状态。若上游行为或可用性变化，发布前应同步更新。

## 必需依赖

| 依赖 | 上游仓库 | 在工作流中的作用 | 级别 | 当前基线 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `openspec-propose` | <https://github.com/Fission-AI/OpenSpec> | 生成 change 及首批 proposal、design、tasks 产物 | Required | Repository-level baseline | 本工作流的主要 OpenSpec 入口 |
| `openspec-verify-change` | <https://github.com/Fission-AI/OpenSpec> | 在归档前校验实现与变更产物是否一致 | Required | Repository-level baseline | 需要在仓库级验证之后执行 |
| `openspec-archive-change` | <https://github.com/Fission-AI/OpenSpec> | 完成最终归档并关闭 OpenSpec 流程 | Required | Repository-level baseline | 分支收尾前的最后一道 OpenSpec 关卡 |

## 推荐依赖

| 依赖 | 上游仓库 | 在工作流中的作用 | 级别 | 当前基线 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `writing-plans` | <https://github.com/obra/superpowers> | 生成与 spec 对齐的可执行计划 | Recommended | Repository-level baseline | 标准的计划到执行交接 |
| `finishing-a-development-branch` | <https://github.com/obra/superpowers> | 做最终分支收尾 | Recommended | Repository-level baseline | 验证后的最后一道护栏 |
| `test-driven-development` | <https://github.com/obra/superpowers> | 约束实现纪律 | Recommended | Repository-level baseline | 执行阶段的参考基线 |
| `subagent-driven-development` | <https://github.com/obra/superpowers> | 在可用时优先用于执行 | Recommended | Repository-level baseline | 支持在 change 内并行推进 |
| `openspec-explore` | <https://github.com/Fission-AI/OpenSpec> | 在进入 proposal 前，用同一套 OpenSpec 语境做探索 | Recommended | Repository-level baseline | 适合先做问题澄清的会话 |

## 可选路径

| 依赖 | 上游仓库 | 在工作流中的作用 | 级别 | 当前基线 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `openspec-new-change` | <https://github.com/Fission-AI/OpenSpec> | 实验性的 change 初始化路径 | Optional | Repository-level baseline | 仅在需要 artifact-first 流程时使用 |
| `openspec-continue-change` | <https://github.com/Fission-AI/OpenSpec> | 继续推进已有 change | Optional | Repository-level baseline | 适合恢复未完成的 OpenSpec change |
| `openspec-ff-change` | <https://github.com/Fission-AI/OpenSpec> | 在实验路径中加速产物推进 | Optional | Repository-level baseline | 宿主支持情况可能不同 |
| `openspec-apply-change` | <https://github.com/Fission-AI/OpenSpec> | 标准实现交接入口 | Optional | Repository-level baseline | 本工作流通常使用自己的第 5 阶段执行路径 |
| `openspec-sync-specs` | <https://github.com/Fission-AI/OpenSpec> | 把 delta specs 同步回主 specs | Optional | Repository-level baseline | 适合维护长生命周期 spec 树的仓库 |

## 版本说明

我们以仓库级别追踪基线，不锁定具体 tag 或 commit。每次发布前，都要重新确认 `superpowers:*` 和当前 `openspec-*` skills 仍然符合预期。
