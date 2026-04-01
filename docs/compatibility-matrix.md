# Compatibility Matrix / 兼容矩阵

| Host | Installation Method | Skill Discovery | External Execution | Script Support | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Codex | Manual, helper script | Partial | Partial | Partial | Partial | Public guidance exists but full host-specific execution still needs end-to-end validation before declaring full support. |
| Claude Code | Manual, helper script | Partial | Experimental | Partial | Experimental | The workflow can be linked into Claude Code, but the host-specific external execution wrapper is still under validation. |
| Gemini CLI | Manual, helper script | Partial | Experimental | Partial | Experimental | Manual installation instructions exist, but the CLI acceleration and discovery flow require additional testing. |
| opencode | Manual, helper script | Partial | Partial | Partial | Partial | The opencode path is the most concrete execution route so far, yet public verification remains pending. |

中文说明：

- Codex：已有文档和路径线索，但还没做完整端到端验证
- Claude Code：已提供安装说明，但外部执行封装仍在验证
- Gemini CLI：有安装说明，发现与执行路径还需更多验证
- opencode：当前实现最具体，但公开验证仍未补齐

## Reading This Matrix / 如何理解这张表

Each row lists the conservative status we can claim today. `Supported` is reserved for paths with documented verification artifacts; all current statuses are `Partial` or `Experimental` until we confirm a host end-to-end.

这张表采用保守标注。`Supported` 只留给已经有验证材料的路径；在做完完整端到端验证之前，其余路径都只标 `Partial` 或 `Experimental`。

Installation methods mention both manual steps and helper scripts, but hosts must still perform the verification checklist in `docs/installation/verify.md` after linking the workflow.

安装方式同时列出手动步骤和辅助脚本，但无论哪种方式，接入后都还要执行 `docs/installation/verify.md` 里的验证清单。

## Current Recommendation / 当前建议

Treat every host listed here as a validation target. Do not assume feature parity across tools; instead, consult the host-specific installation doc and the compatibility matrix before escalating a release.

这里列出的每个宿主都应视为需要单独验证的目标。不要假设不同工具之间天然等价；在推进发布前，先查对应的宿主安装文档和兼容矩阵。
