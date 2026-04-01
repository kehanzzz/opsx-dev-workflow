# OpsX Development Workflow

[English](README.md)

一个面向结构化端到端交付的工作流 skill。

## 为什么要用这套工作流

OpsX Development Workflow 的目标不是替代上游 skill，而是把探索、规格、计划、实现、验证、归档和分支收尾串成一条明确的交付链路，并补上状态记录、审查纪律和回退路径。

## 核心原则

- 先工作流，后工具
- 明确阶段，不靠隐式行为
- 上游依赖保持外置
- 面向多宿主，避免绑死单一工具
- 先验证，再宣告完成

## 工作流结构

这套工作流分成 8 个阶段：

1. 探索
2. 分支准备
3. 创建 change 与 spec
4. 写计划
5. 执行
6. 验证
7. 归档
8. 分支收尾

完整说明见 [工作流概览](docs/zh/workflow-overview.md)。

## 仓库包含什么

- `skill/` 下的工作流 skill 本体
- `skill/` 下的 references、assets 和脚本
- 面向公开发布的安装、依赖、兼容性和排障文档
- 可选的安装与验证辅助脚本

## 仓库不做什么

- 不 vendoring 上游 skill 仓库
- 不替代上游仓库本身
- 不承诺所有宿主行为完全一致
- 不把安装脚本当成主产品

## 上游依赖

当前上游依赖有两个：

- `superpowers`：<https://github.com/obra/superpowers>
- `OpenSpec`：<https://github.com/Fission-AI/OpenSpec>

本仓库记录的是集成基线和角色分工，不镜像它们的内容。

## 快速开始

1. 阅读 [安装总览](docs/zh/installation/overview.md)
2. 按 [上游依赖](docs/zh/upstream-dependencies.md) 准备上游能力
3. 把 `skill/` 链接或复制到宿主的本地 skill 目录
4. 按 [安装验证](docs/zh/installation/verify.md) 做检查

## 支持的宿主

- Codex
- Claude Code
- Gemini CLI
- opencode

当前支持状态见 [兼容矩阵](docs/zh/compatibility-matrix.md)。

## 文档索引

### 中文

- [工作流概览](docs/zh/workflow-overview.md)
- [设计原则](docs/zh/design-principles.md)
- [安装总览](docs/zh/installation/overview.md)
- [上游依赖](docs/zh/upstream-dependencies.md)
- [兼容矩阵](docs/zh/compatibility-matrix.md)
- [故障排查](docs/zh/troubleshooting.md)
- [发布清单](docs/zh/release-checklist.md)
- [仓库元数据](docs/zh/repository-metadata.md)
- [首个 Release 草案](docs/zh/first-release.md)
- [Issue 标签建议](docs/zh/issue-labels.md)
- [GitHub 首发操作清单](docs/zh/github-launch-runbook.md)

### English

- [English README](README.md)
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

## 当前状态

当前仓库已经可以进行首次公开发布，但兼容性声明仍应保持保守，直到每个宿主路径都完成当前基线下的端到端验证。
