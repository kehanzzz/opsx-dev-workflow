# Minimal usage example

This file records the CLI entry you use to make sure the OpsX workflow starts. Keep it minimal so you can adapt it per host.

这个文件只保留最小触发示例，用来确认 OpsX 工作流已经被宿主正确加载。内容尽量简短，方便按宿主改写。

## Invocation

```
<host> skill run examples/minimal-usage.md
```

Replace `<host>` with the CLI name for your environment (e.g., `codex`, `claude`, `gemini`, or `opencode`). The goal is to see the workflow skill return a short confirmation that the spec/plan gate is active.

把 `<host>` 替换成你当前环境里的 CLI 名称，例如 `codex`、`claude`、`gemini` 或 `opencode`。目标不是完整执行，而是确认 workflow skill 能正常启动，并明确返回 spec/plan gate 已进入。
