# 首个 Release 草案

## 建议标签

`v0.1.0`

理由：

- 公开仓库结构已经成型
- 安装文档和辅助脚本已具备
- 兼容性声明仍保持保守，适合先发 `0.x`

## 建议标题

`v0.1.0: Initial public release`

## Release 正文

```md
## 本次发布

- OpsX Development Workflow 首个公开版本
- 补齐安装、兼容性、排障和发布准备文档
- 提供 Codex、Claude Code、Gemini CLI、opencode 的宿主说明
- OpenSpec 命名已对齐到当前 `openspec-*` skill 基线
- 提供前置检查和安装验证辅助脚本

## 这是什么

OpsX Development Workflow 是一个 workflow skill，用来把探索、change/spec 创建、计划、执行、验证、归档和分支收尾串成一条明确的交付路径。

它建立在两个上游项目之上，而不是替代它们：

- `obra/superpowers`
- `Fission-AI/OpenSpec`

## 当前支持声明

这个版本对兼容性声明保持保守。具体以仓库中的兼容矩阵为准。

## 补充说明

- `skill/` 是公开安装单元
- 本仓库不 vendoring 上游依赖
- 在各宿主都做完端到端验证前，不承诺完全一致的行为
```
