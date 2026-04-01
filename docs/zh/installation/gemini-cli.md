# Gemini CLI 集成说明

Gemini CLI 会从你配置的本地 skill 目录加载 workflow。本仓库不假设 Gemini CLI 只有一个固定默认路径。

## 宿主差异

- 安装你实际使用的 Gemini CLI 工具链，并确认它可以加载本地 skills。
- 把 `skill/opsx-development-workflow` 放到配置好的 skill 目录中，或为它创建软链接。
- 确认 Gemini CLI 能在 skill 列表或等价输出里发现 `opsx-development-workflow`。
- 用 Gemini CLI 的正常 skill 调用方式触发本工作流，并配合 [examples/minimal-usage.md](../../../examples/minimal-usage.md) 中的提示文本做检查。

## 下一步

当宿主能识别该 skill 后，继续执行 [安装验证](verify.md)，确认验证步骤和上游通信正常。

## 上游提醒

本仓库依赖 `https://github.com/obra/superpowers` 和 `https://github.com/Fission-AI/OpenSpec`。Gemini CLI 会直接引用这些上游 skill 源，本仓库不复制它们。
