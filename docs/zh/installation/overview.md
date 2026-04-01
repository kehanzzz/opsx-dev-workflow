# 安装总览

本项目的主体是 OpsX Development Workflow skill。推荐安装方式仍然是手动安装：先读文档、准备上游依赖、再把 skill 注册到宿主。`scripts/` 下的脚本只用于加速检查，不替代文档；上游 skill 仍然保持外置。

## 推荐路径

1. **克隆本仓库** 到宿主可访问的位置，并保持路径稳定。
2. **准备上游依赖**：
   - `https://github.com/obra/superpowers`：当前工作流 skill 宿主，按其 README 安装并保持更新。
   - `https://github.com/Fission-AI/OpenSpec`：负责 spec 和计划阶段，和本工作流一起放到 agent 宿主可访问的 skill 目录。
3. **向宿主注册 OpsX skill**：把 `skill/` 复制或软链接到宿主使用的 skill 目录，必要时重启宿主，并确认 skill 列表里能看到 `opsx-development-workflow`。

手动安装是主路径。完成以上步骤后，再按 [安装验证](verify.md) 执行验证，确认 skill 能被宿主发现，也能连到上游依赖。

## 可选辅助脚本

`scripts/` 目录包含：

- `check-prerequisites.sh`
- `install.sh`
- `verify-install.sh`

这些脚本只用于加速检查，不能替代文档本身。

## 宿主差异

- [Codex](codex.md)
- [Claude Code](claude-code.md)
- [Gemini CLI](gemini-cli.md)
- [opencode](opencode.md)

这里说明的是公共安装步骤；每个宿主页面负责补充各自的差异。

## 验证提醒

在宿主成功加载 skill 后，继续执行 [安装验证](verify.md)。这份验证文档与宿主无关，但会说明如何套用 `examples/minimal-usage.md` 里的最小触发示例。

## 上游提醒

OpsX 依赖上面列出的两个上游仓库。本仓库只说明如何把它们组合起来使用，不打包它们的源码，也不替代它们的发布节奏。
