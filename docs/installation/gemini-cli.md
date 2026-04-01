# Gemini CLI integration notes

Gemini CLI should load the workflow from the local skill directory configured in your installation. This repository does not assume a fixed default path for Gemini CLI.

## Host-specific differences

- Install the Gemini CLI tooling you actually use and make sure it can load local skills.
- Place `skill/opsx-development-workflow` inside the configured skill directory or create a symlink there.
- Confirm that Gemini CLI can discover `opsx-development-workflow` through its skill list or equivalent host output.
- Trigger the workflow using Gemini CLI's normal named-skill invocation flow and the prompt text from [examples/minimal-usage.md](../../examples/minimal-usage.md).

## Next step

With the host recognizing the skill, proceed to [verify.md](verify.md) to replay the verification steps and confirm upstream communication.

## Upstream reminder

This repository depends on `https://github.com/obra/superpowers` and `https://github.com/Fission-AI/OpenSpec`. Gemini CLI references the upstream skill sources directly; OpsX does not vendor or replicate them.
