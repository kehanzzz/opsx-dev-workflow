# Claude Code integration notes

Claude Code should load the workflow from whatever local skill directory or workspace your installation is configured to use. This repository does not assume a fixed default path for Claude Code.

## Host-specific differences

- Install the Claude Code tooling you actually use and confirm it can load local skills from your configured workspace.
- Link or copy `skill/` into that workspace's skill directory.
- Confirm that Claude Code can discover `opsx-development-workflow` through its skill list or equivalent host UI.
- Trigger the workflow using Claude Code's normal named-skill invocation flow and the prompt text from [examples/minimal-usage.md](../../examples/minimal-usage.md).

## Next step

After the skill is visible in Claude Code, follow [verify.md](verify.md) to confirm the workflow stage transitions and minimal trigger.

## Upstream reminder

OpsX relies on `https://github.com/obra/superpowers` and `https://github.com/Fission-AI/OpenSpec`. This repository documents how Claude Code should point to those upstream skills; it does not mirror their repositories.
