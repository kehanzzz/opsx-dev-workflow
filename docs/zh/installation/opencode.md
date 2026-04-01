# opencode 集成说明

opencode 使用本地 skill 目录。一个常见路径是 `~/.config/opencode/skills`，因此可以把 workflow skill 链接或复制到 `~/.config/opencode/skills/opsx-development-workflow`。

## 宿主差异

- 安装 opencode 宿主工具，并确认当前版本可以加载本地 skills。
- 把 `skill/` 链接或复制到 `~/.config/opencode/skills/opsx-development-workflow`。
- 确认 opencode 能在其 skills 视图中发现 `opsx-development-workflow`。
- 用 opencode 的正常 skill 调用方式触发本工作流，并配合 [examples/minimal-usage.md](../../../examples/minimal-usage.md) 中的提示文本做检查。

## 下一步

当宿主确认已经加载该 skill 后，继续执行 [安装验证](verify.md)，确认最小触发和 spec 或 plan gate 正常。

## 上游提醒

该 workflow skill 依赖 `https://github.com/obra/superpowers` 和 `https://github.com/Fission-AI/OpenSpec`。本仓库只说明 opencode 如何接入这些项目，不包含它们的源码。
