# Claude Code 集成说明

Claude Code 会从你配置的本地 skill 目录或工作区加载 workflow。本仓库不假设 Claude Code 只有一个固定默认路径。

## 宿主差异

- 安装你实际使用的 Claude Code 工具链，并确认它可以从配置好的工作区加载本地 skills。
- 把 `skill/` 链接或复制到对应工作区的 skill 目录。
- 确认 Claude Code 能在 skill 列表或等价界面里发现 `opsx-development-workflow`。
- 用 Claude Code 的正常 skill 调用方式触发本工作流，并配合 [examples/minimal-usage.md](../../../examples/minimal-usage.md) 中的提示文本做检查。

## 下一步

当 Claude Code 能看到该 skill 后，继续执行 [安装验证](verify.md)，确认最小触发和阶段切换正常。

## 上游提醒

OpsX 依赖 `https://github.com/obra/superpowers` 和 `https://github.com/Fission-AI/OpenSpec`。本仓库只说明 Claude Code 应如何指向这些上游 skills，不镜像它们的仓库。
