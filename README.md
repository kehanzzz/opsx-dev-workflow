# OpsX Development Workflow

[Chinese](README.zh-CN.md)

An opinionated workflow skill for structured end-to-end software delivery.

## Why This Workflow

OpsX Development Workflow turns fragmented agent work into an explicit delivery flow with clear gates for exploration, specification, planning, implementation, verification, archival, and branch finish. It does not replace strong upstream skills. It makes them work together with consistent state, review discipline, and recovery paths.

## Core Principles

- Workflow first, tooling second
- Explicit gates over implicit agent behavior
- Upstream dependencies stay external
- Host-aware, tool-agnostic orchestration
- Verification before completion

## How The Workflow Is Structured

The workflow is organized around eight stages:

1. Explore
2. Branch setup
3. Change and spec creation
4. Planning
5. Execution
6. Verification
7. Archive
8. Branch finish

See [Workflow overview](docs/workflow-overview.md) for the full stage summary.

## What This Repository Contains

- The workflow skill itself under `skill/`
- Supporting references, assets, and workflow scripts under `skill/`
- Public documentation for installation, dependencies, compatibility, and troubleshooting
- Optional helper scripts for setup checks and install verification

## What This Repository Does Not Do

- It does not vendor upstream skill repositories.
- It does not replace upstream repositories.
- It does not guarantee identical behavior across every declared host.
- It does not treat installation helpers as the primary product.

## Upstream Dependencies

This workflow currently integrates against these upstream repositories:

- `superpowers`: <https://github.com/obra/superpowers>
- `OpenSpec`: <https://github.com/Fission-AI/OpenSpec>

This repository documents the integration baseline and expected roles for those dependencies. It does not mirror their contents.

## Quick Start

1. Read [Installation overview](docs/installation/overview.md).
2. Prepare the upstream dependencies listed in [Upstream dependencies](docs/upstream-dependencies.md).
3. Link or copy `skill/` into your local skill directory for your host.
4. Run the checks in [Installation verification](docs/installation/verify.md).

## Supported Hosts

- Codex
- Claude Code
- Gemini CLI
- opencode

See [Compatibility matrix](docs/compatibility-matrix.md) for current support levels.

## Documentation

### English

- [Workflow overview](docs/workflow-overview.md)
- [Design principles](docs/design-principles.md)
- [Installation overview](docs/installation/overview.md)
- [Upstream dependencies](docs/upstream-dependencies.md)
- [Compatibility matrix](docs/compatibility-matrix.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Release checklist](docs/release-checklist.md)
- [Repository metadata](docs/repository-metadata.md)
- [First release draft](docs/first-release.md)
- [Issue labels](docs/issue-labels.md)
- [GitHub launch runbook](docs/github-launch-runbook.md)

### Chinese

- [Chinese home](README.zh-CN.md)
- [Workflow overview (ZH)](docs/zh/workflow-overview.md)
- [Design principles (ZH)](docs/zh/design-principles.md)
- [Installation overview (ZH)](docs/zh/installation/overview.md)
- [Upstream dependencies (ZH)](docs/zh/upstream-dependencies.md)
- [Compatibility matrix (ZH)](docs/zh/compatibility-matrix.md)
- [Troubleshooting (ZH)](docs/zh/troubleshooting.md)
- [Release checklist (ZH)](docs/zh/release-checklist.md)
- [Repository metadata (ZH)](docs/zh/repository-metadata.md)
- [First release draft (ZH)](docs/zh/first-release.md)
- [Issue labels (ZH)](docs/zh/issue-labels.md)
- [GitHub launch runbook (ZH)](docs/zh/github-launch-runbook.md)

## Project Status

This repository is ready for an initial public release. Public docs and installation helpers are available, but compatibility claims should remain conservative until each host path is validated against the current integration baseline.
