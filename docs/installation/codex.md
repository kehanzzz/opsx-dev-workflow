# Codex integration notes

Codex uses a local skills directory. A common path is `~/.codex/skills`, so the OpsX workflow skill can be linked or copied there as `~/.codex/skills/opsx-development-workflow`.

## Host-specific differences

- Ensure the Codex CLI can refresh or re-read its local skills directory after you add the workflow.
- Link or copy `skill/` into `~/.codex/skills/opsx-development-workflow`.
- Confirm that Codex can discover `opsx-development-workflow` from its skill list or equivalent skill-discovery view.
- Trigger the workflow using Codex's normal named-skill invocation flow and the prompt text from [examples/minimal-usage.md](../../examples/minimal-usage.md).

## Next step

Once Codex can see the skill, follow [verify.md](verify.md) to replay the host-agnostic verification checklist.

## Upstream reminder

The OpsX workflow depends on `https://github.com/obra/superpowers` and `https://github.com/Fission-AI/OpenSpec`. This repository only outlines how to integrate those upstream skills with Codex; their source code is not vendored here.
