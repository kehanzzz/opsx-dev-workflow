# OpsX Development Workflow

An opinionated workflow skill for structured end-to-end software delivery.

一个面向结构化端到端交付的工作流 skill。

## Why This Workflow

OpsX Development Workflow exists to turn fragmented agent work into an explicit delivery flow with clear gates for exploration, specification, planning, implementation, verification, archival, and branch finish. The goal is not to replace strong upstream skills. The goal is to make them work together with consistent state, review discipline, and recovery paths.

OpsX Development Workflow 的目标，不是替代上游 skill，而是把探索、规格、计划、实现、验证、归档和分支收尾串成一条明确的交付链路，并补上状态记录、审查纪律和回退路径。

## Core Principles

- Workflow first, tooling second
- Explicit gates over implicit agent behavior
- Upstream dependencies stay external
- Host-aware, tool-agnostic orchestration
- Verification before completion

核心原则：

- 先工作流，后工具
- 明确阶段，不靠隐式行为
- 上游依赖保持外置
- 面向多宿主，避免绑死单一工具
- 先验证，再宣告完成

## How The Workflow Is Structured

The workflow is organized around eight stages:

1. Explore
2. Branch setup
3. Change and spec creation
4. Planning
5. Execution
6. Verification
7. Archive
8. Branch finish

See [workflow-overview.md](docs/workflow-overview.md) for the full stage summary.

工作流分成 8 个阶段：探索、分支准备、创建 change/spec、写计划、执行、验证、归档、分支收尾。完整说明见 [workflow-overview.md](docs/workflow-overview.md)。

## What This Repository Contains

- The workflow skill itself under `skill/`
- Supporting references, assets, and workflow scripts under `skill/`
- Public documentation for installation, dependencies, compatibility, and troubleshooting
- Optional helper scripts for setup checks and install verification

仓库内容：

- `skill/` 下的工作流 skill 本体
- `skill/` 下的 references、assets 和脚本
- 面向公开发布的安装、依赖、兼容性和排障文档
- 可选的安装与验证辅助脚本

## What This Repository Does Not Do

- It does not vendor upstream skill repositories.
- It does not replace upstream repositories.
- It does not guarantee identical behavior across every declared host.
- It does not treat installation helpers as the primary product.

这个仓库不做几件事：

- 不 vendoring 上游 skill 仓库
- 不替代上游仓库本身
- 不承诺所有宿主行为完全一致
- 不把安装脚本当成主产品

## Upstream Dependencies

This workflow currently integrates against these upstream repositories:

- `superpowers`: <https://github.com/obra/superpowers>
- `OpenSpec`: <https://github.com/Fission-AI/OpenSpec>

This repository documents the integration baseline and expected roles for those dependencies. It does not mirror their contents.

当前上游依赖有两个：

- `superpowers`：<https://github.com/obra/superpowers>
- `OpenSpec`：<https://github.com/Fission-AI/OpenSpec>

本仓库记录的是集成基线和角色分工，不镜像它们的内容。

## Quick Start

1. Read [installation overview](docs/installation/overview.md).
2. Prepare the upstream dependencies listed in [upstream-dependencies.md](docs/upstream-dependencies.md).
3. Link or copy `skill/` into your local skill directory for your host.
4. Run the checks in [verify.md](docs/installation/verify.md).

快速开始：

1. 阅读 [installation overview](docs/installation/overview.md)
2. 按 [upstream-dependencies.md](docs/upstream-dependencies.md) 准备上游依赖
3. 把 `skill/` 链接或复制到宿主的本地 skill 目录
4. 按 [verify.md](docs/installation/verify.md) 做验证

## Supported Hosts

- Codex
- Claude Code
- Gemini CLI
- opencode

See [compatibility-matrix.md](docs/compatibility-matrix.md) for current support levels.

当前面向 4 个宿主：Codex、Claude Code、Gemini CLI、opencode。支持状态见 [compatibility-matrix.md](docs/compatibility-matrix.md)。

## Documentation

- [Workflow overview](docs/workflow-overview.md)
- [Design principles](docs/design-principles.md)
- [Installation overview](docs/installation/overview.md)
- [Upstream dependencies](docs/upstream-dependencies.md)
- [Compatibility matrix](docs/compatibility-matrix.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Release checklist](docs/release-checklist.md)
- [Repository metadata](docs/repository-metadata.md)
- [First release draft](docs/first-release.md)
- [Issue labels](docs/issue-labels.md)
- [GitHub launch runbook](docs/github-launch-runbook.md)

## Project Status

This repository is ready for an initial public release. Public docs and installation helpers are available, but compatibility claims should remain conservative until each host path is validated against the current integration baseline.

当前仓库已经可以进行首次公开发布，但兼容性声明仍应保持保守，直到每个宿主路径都完成当前基线下的端到端验证。
