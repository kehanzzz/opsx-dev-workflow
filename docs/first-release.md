# First Release Draft

## Suggested Tag

`v0.1.0`

Reason:

- Public repository shape is ready
- Installation docs and helper scripts are present
- Compatibility claims are still intentionally conservative

## Suggested Title

`v0.1.0: Initial public release`

## Release Body

```md
## Highlights

- Initial public release of the OpsX Development Workflow skill
- Public docs for installation, compatibility, troubleshooting, and release prep
- Host guidance for Codex, Claude Code, Gemini CLI, and opencode
- OpenSpec naming aligned with the current `openspec-*` skill baseline
- Helper scripts for prerequisite checks and install verification

## What This Is

OpsX Development Workflow is a workflow skill that connects exploration, change/spec creation, planning, execution, verification, archive, and branch finish into one explicit delivery path.

It builds on upstream projects instead of replacing them:

- `obra/superpowers`
- `Fission-AI/OpenSpec`

## Current Support Position

This release keeps support claims conservative. Use the compatibility matrix in the repository as the source of truth for host status.

## Notes

- `skill/` is the published installation unit
- upstream dependencies are not vendored into this repository
- host behavior may differ until each path is fully validated end to end
```
