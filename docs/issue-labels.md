# Issue Labels / Issue 标签建议

| Label | Use | 中文说明 |
| --- | --- | --- |
| `bug` | Confirmed defects or regressions | 已确认的缺陷或回归 |
| `docs` | README, installation, troubleshooting, examples | README、安装、排障、示例相关 |
| `release` | Release prep, packaging, metadata, versioning | 发布准备、打包、元数据、版本管理 |
| `installation` | Host-specific setup or environment issues | 宿主安装或环境问题 |
| `compatibility` | Host support gaps across Codex, Claude Code, Gemini CLI, opencode | 多宿主兼容性问题 |
| `upstream` | Changes caused by OpenSpec or superpowers updates | 由 OpenSpec 或 superpowers 更新引发的问题 |
| `workflow` | Stage logic, state flow, verification, archive rules | 阶段逻辑、状态流、验证、归档规则 |
| `enhancement` | Non-breaking improvements to the workflow or docs | 非破坏性的工作流或文档改进 |
| `good first issue` | Safe starting points for new contributors | 适合新贡献者上手 |
| `help wanted` | Work that is open for community contribution | 适合社区协作推进 |

## Minimal Starter Set / 最小起步集合

If you want to keep it lean, start with:

- `bug`
- `docs`
- `installation`
- `compatibility`
- `upstream`
- `enhancement`

如果一开始不想铺太多标签，先用这 6 个就够了。

## Optional Helper / 可选辅助脚本

This repository also includes:

- label data: [../.github/labels.tsv](../.github/labels.tsv)
- sync script: [../scripts/setup-github-labels.sh](../scripts/setup-github-labels.sh)

If you use GitHub CLI, you can initialize or update labels with:

```bash
./scripts/setup-github-labels.sh <owner/repo>
```

如果你使用 GitHub CLI，可以直接用这个脚本初始化或更新 labels。
