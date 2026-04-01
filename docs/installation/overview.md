# Installation Overview

This project centers on the OpsX Development Workflow skill. The recommended installation path is manual: read the steps below, prepare the listed upstream dependencies, and register the skill with your host. Helper scripts under `scripts/` can speed up checks, but they are optional and never replace the guidance in this document. Upstream skill content lives in external repositories; this repo documents how to integrate them, it does not vendor their code.

本项目的主体是 OpsX Development Workflow skill。推荐安装方式仍然是手动安装：先读文档、准备上游依赖、再把 skill 注册到宿主。`scripts/` 下的脚本只用于加速检查，不替代文档；上游 skill 仍然保持外置。

## Recommended path

1. **Clone this repository** somewhere you can reach from your host. Keep the path stable so skill references stay valid.
2. **Prepare upstream dependencies**:
   - `https://github.com/obra/superpowers`: current workflow skill host. Fork or clone it, follow its README for installation in your local environment, and keep it updated.
   - `https://github.com/Fission-AI/OpenSpec`: orchestrates spec/plan stages. Clone it alongside the workflow skill and make sure your agent hosts can reach it via their configured skill directories.
3. **Register the OpsX skill with your host**: copy or symlink the `skill/` directory into the skill slot your host expects, restart the host if needed, and confirm that the host’s skill list shows `opsx-development-workflow`.

Manual installation is the primary workflow. After you complete the steps above, run the verification checklist in [docs/installation/verify.md](verify.md) to ensure the skill can reach your host and upstream dependencies.

手动安装是主路径。完成以上步骤后，再按 [docs/installation/verify.md](verify.md) 执行验证，确认 skill 能被宿主发现，也能连到上游依赖。

## Optional helper scripts

The `scripts/` directory contains:

- `check-prerequisites.sh` for shell environments,
- `install.sh` to mirror the manual steps, and
- `verify-install.sh` to replay the verification steps.

Run them only after you have read this overview and the host-specific guidance; the scripts report their actions and always point back to the documentation.

## Host-specific differences

- [Codex](codex.md)
- [Claude Code](claude-code.md)
- [Gemini CLI](gemini-cli.md)
- [opencode](opencode.md)

Each linked document explains what deviates from the manual path above. Common steps (clone, prepare upstream, link the `skill/` directory) belong here; the host docs describe CLI names, tokens, and environment variables that change per host.

## Verification reminder

After you start the host with this skill in place, run the steps in [docs/installation/verify.md](verify.md). The verification doc is host-agnostic but tells you how to adapt to the minimal trigger example in `examples/minimal-usage.md`.

## Upstream reminder

OpsX depends on the two upstream repositories listed above. This repository only documents how to combine them; it does not bundle their source code or replace their release cadence. Always pull updates directly from the upstream origins before trusting new features.
