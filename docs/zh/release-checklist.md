# 发布清单

## 仓库门面

- README 与当前工作流定位一致
- `skill/` 是公开安装单元
- 仓库描述、topics 和 release 文案已经在 [repository-metadata.md](repository-metadata.md) 与 [first-release.md](first-release.md) 中准备好

## 依赖基线

- 上游依赖链接有效，并指向当前集成基线
- OpenSpec 命名已对齐当前的 `openspec-*` skills
- 兼容性状态与真实验证结果一致
- 如果上游宿主别名变更，公开文档已跟上，而不是继续沿用旧简称

## 文档

- Codex、Claude Code、Gemini CLI、opencode 的安装说明都已存在
- 最小使用示例仍然匹配当前 workflow 名称
- 排障文档反映当前依赖和安装结构
- `docs/zh/upstream-dependencies.md` 仍明确声明上游仓库保持外置

## 验证

- 辅助脚本本地检查通过
- `./scripts/check-prerequisites.sh` 通过
- `./scripts/verify-install.sh` 通过
- `bash -n scripts/*.sh skill/scripts/*.sh` 通过
- 如果使用可选的 label 同步脚本，`gh` 已安装且已登录

## 发布材料

- 首个 Release 文案已准备在 [first-release.md](first-release.md)
- 推荐的 issue labels 已准备在 [issue-labels.md](issue-labels.md)
- GitHub 首发步骤已记录在 [github-launch-runbook.md](github-launch-runbook.md)
- Release 文案中的保守支持声明与兼容矩阵一致
