# Codex 集成说明

Codex 使用本地 skill 目录。一个常见路径是 `~/.codex/skills`，因此可以把 OpsX workflow skill 链接或复制到 `~/.codex/skills/opsx-development-workflow`。

## 宿主差异

- 确认 Codex CLI 在添加 workflow 后能够刷新本地 skill 目录。
- 把 `skill/` 链接或复制到 `~/.codex/skills/opsx-development-workflow`。
- 确认 Codex 能在 skill 列表或等价的发现视图里看到 `opsx-development-workflow`。
- 用 Codex 的正常 skill 调用方式触发本工作流，并配合 [examples/minimal-usage.md](../../../examples/minimal-usage.md) 中的提示文本做检查。

## 下一步

当 Codex 能识别该 skill 后，继续执行 [安装验证](verify.md)。

## 上游提醒

OpsX workflow 依赖 `https://github.com/obra/superpowers` 和 `https://github.com/Fission-AI/OpenSpec`。本仓库只说明如何把这些上游能力接到 Codex，不 vendoring 它们的源码。
