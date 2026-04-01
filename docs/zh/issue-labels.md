# Issue 标签建议

| 标签 | 用途 |
| --- | --- |
| `bug` | 已确认的缺陷或回归 |
| `docs` | README、安装、排障、示例相关 |
| `release` | 发布准备、打包、元数据、版本管理 |
| `installation` | 宿主安装或环境问题 |
| `compatibility` | 多宿主兼容性问题 |
| `upstream` | 由 OpenSpec 或 superpowers 更新引发的问题 |
| `workflow` | 阶段逻辑、状态流、验证、归档规则 |
| `enhancement` | 非破坏性的工作流或文档改进 |
| `good first issue` | 适合新贡献者上手 |
| `help wanted` | 适合社区协作推进 |

## 最小起步集合

如果一开始不想铺太多标签，先用这 6 个就够了：

- `bug`
- `docs`
- `installation`
- `compatibility`
- `upstream`
- `enhancement`

## 可选辅助脚本

本仓库还包含：

- 标签数据：[../.github/labels.tsv](../.github/labels.tsv)
- 同步脚本：[../scripts/setup-github-labels.sh](../scripts/setup-github-labels.sh)

如果你使用 GitHub CLI，可以直接执行：

```bash
./scripts/setup-github-labels.sh <owner/repo>
```
