# opencode integration notes

opencode uses a local skills directory. A common path is `~/.config/opencode/skills`, so the workflow skill can be linked or copied there as `~/.config/opencode/skills/opsx-development-workflow`.

## Host-specific differences

- Install the opencode host tooling and confirm your version can load local skills.
- Link or copy `skill/` into `~/.config/opencode/skills/opsx-development-workflow`.
- Confirm that opencode can discover `opsx-development-workflow` from its configured skills view.
- Trigger the workflow using opencode's normal named-skill invocation flow and the prompt text from [examples/minimal-usage.md](../../examples/minimal-usage.md).

## Next step

After the host acknowledges the skill, follow [verify.md](verify.md) to validate the minimal trigger and confirm the workflow reaches the spec/plan gate.

## Upstream reminder

The workflow skill relies on `https://github.com/obra/superpowers` and `https://github.com/Fission-AI/OpenSpec`. This repository only documents how opencode hooks into those projects; their source code stays in upstream repositories.
