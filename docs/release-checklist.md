# Release Checklist

## Repository Surface

- README matches the current workflow scope and positioning.
- `skill/` is the published installation unit.
- Repository description, topics, and release copy are prepared in [repository-metadata.md](repository-metadata.md) and [first-release.md](first-release.md).

## Dependency Baseline

- Upstream dependency links are valid and point to the current integration baseline.
- OpenSpec naming matches the current upstream `openspec-*` skills.
- Compatibility statuses match actual validation results.
- If host-specific aliases changed upstream, the public docs follow upstream naming rather than older local shorthand.

## Documentation

- Installation guides exist for Codex, Claude Code, Gemini CLI, and opencode.
- Minimal usage examples still match the workflow name.
- Troubleshooting reflects the current required dependencies and install shape.
- `docs/upstream-dependencies.md` still states that upstream repos remain external.

## Verification

- Helper scripts pass local checks.
- `./scripts/check-prerequisites.sh` passes.
- `./scripts/verify-install.sh` passes.
- `bash -n scripts/*.sh skill/scripts/*.sh` passes.
- If you use the optional GitHub label sync helper, `gh` is installed and authenticated.

## Release Assets

- First release notes are ready in [first-release.md](first-release.md).
- Recommended issue labels are ready in [issue-labels.md](issue-labels.md).
- GitHub launch steps are documented in [github-launch-runbook.md](github-launch-runbook.md).
- Any conservative support claim in the release notes matches the compatibility matrix.
