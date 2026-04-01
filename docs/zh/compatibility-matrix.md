# 兼容矩阵

| Host | 安装方式 | Skill 发现 | 外部执行 | 脚本支持 | 状态 | 说明 |
| --- | --- | --- | --- | --- | --- | --- |
| Codex | 手动，辅助脚本 | Partial | Partial | Partial | Partial | 已有文档和路径线索，但还没做完整端到端验证。 |
| Claude Code | 手动，辅助脚本 | Partial | Experimental | Partial | Experimental | 已提供安装说明，但宿主特定的外部执行封装仍在验证。 |
| Gemini CLI | 手动，辅助脚本 | Partial | Experimental | Partial | Experimental | 已有安装说明，但发现与执行路径还需更多验证。 |
| opencode | 手动，辅助脚本 | Partial | Partial | Partial | Partial | 当前实现最具体，但公开验证仍未补齐。 |

## 如何理解这张表

这张表采用保守标注。`Supported` 只留给已经有验证材料的路径；在做完完整端到端验证之前，其余路径都只标 `Partial` 或 `Experimental`。

安装方式同时列出手动步骤和辅助脚本，但无论哪种方式，接入后都还要执行 `docs/zh/installation/verify.md` 里的验证清单。

## 当前建议

这里列出的每个宿主都应视为需要单独验证的目标。不要假设不同工具之间天然等价；在推进发布前，先查对应的宿主安装文档和兼容矩阵。
