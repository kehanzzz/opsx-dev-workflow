# GitHub Launch Runbook / GitHub 首发操作清单

这份文档不是设计说明，而是首发当天可以直接照着走的顺序。

## 1. 完成仓库门面

在 GitHub 仓库页填好以下内容：

- Description：使用 [repository-metadata.md](repository-metadata.md) 里的推荐文案
- Topics：从 [repository-metadata.md](repository-metadata.md) 里选 8 到 12 个
- README：确认默认展示的是当前版本
- License：确认仓库已显示许可证

建议先把 About 区域配好，再发 release。

## 2. 建立基础标签

先创建最小集合：

- `bug`
- `docs`
- `installation`
- `compatibility`
- `upstream`
- `enhancement`

如果你想一步到位，再补：

- `release`
- `workflow`
- `good first issue`
- `help wanted`

标签说明见 [issue-labels.md](issue-labels.md)。

如果你已经安装并登录 GitHub CLI，也可以直接执行：

```bash
./scripts/setup-github-labels.sh <owner/repo>
```

## 3. 检查公开文档入口

发布前手动点一遍这些入口：

- [README.md](../README.md)
- [docs/installation/overview.md](installation/overview.md)
- [docs/upstream-dependencies.md](upstream-dependencies.md)
- [docs/compatibility-matrix.md](compatibility-matrix.md)
- [docs/troubleshooting.md](troubleshooting.md)

重点检查两件事：

- 公开入口是不是都还在
- 命名是不是已经统一到 `openspec-*`

## 4. 跑发布前检查

在仓库根目录执行：

```bash
bash -n scripts/*.sh skill/scripts/*.sh
./scripts/check-prerequisites.sh
./scripts/verify-install.sh
```

如果这里不过，不要先发 release。

如果你准备使用 label 同步脚本，再额外确认本机有 `gh`，并且已经完成 `gh auth login`。

## 5. 创建首个 Release

建议：

- Tag：`v0.1.0`
- Title：`v0.1.0: Initial public release`

正文可直接从 [first-release.md](first-release.md) 复制，再按你当时的验证状态微调。

## 6. 发布后补第一轮信号

发布完成后，优先观察这几类反馈：

- 安装问题
- 宿主兼容性问题
- 对工作流定位的误解
- 对上游依赖关系的误解

这些反馈通常最先决定 README 和安装文档要不要再收一轮。

## 7. 首发后建议动作

如果首发顺利，下一轮优先做：

1. 给 Codex 和 opencode 各补一次端到端验证记录
2. 把兼容矩阵里的保守状态更新到有证据的状态
3. 从真实 issue 中反推 README 和 troubleshooting 的薄弱点
