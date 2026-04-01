# Release Checklist / 发布清单

## Repository Surface / 仓库门面

- README matches the current workflow scope and positioning.
- README 里的定位要明确：主产品是 workflow skill，不是安装脚本。
- `skill/` is the published installation unit.
- 公开文档里不能再出现过时的顶层 `skills/` 安装路径。
- Repository description, topics, and release copy are prepared in [repository-metadata.md](repository-metadata.md) and [first-release.md](first-release.md).

## Dependency Baseline / 依赖基线

- Upstream dependency links are valid and point to the current integration baseline.
- OpenSpec naming matches the current upstream `openspec-*` skills.
- Compatibility statuses match actual validation results.
- If host-specific aliases changed upstream, the public docs follow upstream naming rather than older local shorthand.

## Documentation / 文档

- Installation guides exist for Codex, Claude Code, Gemini CLI, and opencode.
- Minimal usage examples still match the workflow name.
- Troubleshooting reflects the current required dependencies and install shape.
- `docs/upstream-dependencies.md` still states that upstream repos remain external.

## Verification / 验证

- Helper scripts pass local checks.
- `./scripts/check-prerequisites.sh` passes.
- `./scripts/verify-install.sh` passes.
- `bash -n scripts/*.sh skill/scripts/*.sh` passes.
- If you use the optional GitHub label sync helper, `gh` is installed and authenticated.

## Release Assets / 发布材料

- First release notes are ready in [first-release.md](first-release.md).
- Recommended issue labels are ready in [issue-labels.md](issue-labels.md).
- GitHub launch steps are documented in [github-launch-runbook.md](github-launch-runbook.md).
- Any conservative support claim in the release notes matches the compatibility matrix.
