# Installation verification

Use this checklist once you have completed the manual installation path and any host-specific mapping. The goal is to confirm that a host can load `opsx-development-workflow`, reach the upstream dependencies (`obra/superpowers` and `Fission-AI/OpenSpec`), and trigger the minimal workflow sequence documented in [examples/minimal-usage.md](../../examples/minimal-usage.md).

## Repository checks

Run:

```bash
find skill -maxdepth 2 -type f | sort
./scripts/check-prerequisites.sh
./scripts/verify-install.sh
```

Expected:

- `skill/SKILL.md` exists
- `skill/references/` exists
- `skill/assets/` exists
- `skill/scripts/` exists
- helper scripts report success

## Minimal verification checklist

1. Start the host according to the matching installation page and let it refresh its skill registry.
2. Confirm that `opsx-development-workflow` is visible in the host's skill list or equivalent discovery view.
3. Trigger the workflow using the prompt text in [examples/minimal-usage.md](../../examples/minimal-usage.md).
4. Review the response and confirm the workflow acknowledges the explore/spec/plan path rather than behaving like a plain one-off prompt.

## Why verification matters

Running this checklist proves two things:

- Your host is pointing at the OpsX skill in this repository.
- The skill can call into `obra/superpowers` and `Fission-AI/OpenSpec` to orchestrate the workflow stages.

If any step fails, revisit the host-specific instructions and confirm the skill path and host configuration before assuming the workflow itself is broken.

## Upstream reminder

The workflow skill integrates with `https://github.com/obra/superpowers` and `https://github.com/Fission-AI/OpenSpec`; this repository documents that integration and does not include their sources.
