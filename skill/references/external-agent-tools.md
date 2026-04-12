# External Execution Tool Adaptation

This skill does not lock Step 5 to a single tool. `opencode` is the only runnable wrapper today. `claude-code` remains a documented placeholder until a runnable wrapper exists. Any future external execution agent may be used so long as it satisfies the same constraints:

- The primary agent is responsible for the plan, boundaries, acceptance criteria, and verification rules.
- The external execution agent handles implementation.
- The primary agent handles reviews or final acceptance.
- TDD, scope control, and verification discipline must not be relaxed due to a tool switch.
- The current agent must proactively initiate the tool call, preferably via CLI or an equivalent command interface available in the environment.

## Tool Selection Rules

- If the user explicitly names a tool, use that tool.
- If the user does not specify a tool, the primary agent must confirm which tool to use before entering external execution.
- Explicitly supported today:
  - `opencode`
- `claude-code` remains a documented placeholder until a runnable wrapper exists.
- Do not assume a tool or enter external execution before the user confirms the choice.

## Adaptation Principles

Every tool integration has two layers:

1. **Prompt body**
   - Reuse the generic prompt bodies in `assets/`.
   - Do not hardcode tool-specific command syntax into the prompt body.
2. **Tool wrapper**
   - Wrap the prompt body with the CLI command, task API, or sub-agent orchestration of the chosen tool.
   - When switching tools, only the wrapper changes; the core workflow rules stay the same.

## Invocation Requirements

- Prefer CLI invocation when the tool supports it.
- If CLI is unavailable, use whichever command interface in the current environment is equivalent to a direct call.
- Drafting the prompt without executing the call does not complete Step 5.
- Giving the user a command to run manually also does not complete Step 5.
- Prefer running `scripts/init-change-state.sh <change-id>` first, then `scripts/start-execution-mode.sh` to record the mode and tool, and reuse `scripts/run-external-tool.sh` as the standard entry point instead of crafting ad-hoc commands every time.

## Supported Adaptation Targets

### `opencode`

- Well suited to wrapping a complete prompt via CLI.
- Fill the prompt body from `assets/` and submit it with `opencode run` or a similar invocation.
- This skill already provides the `scripts/run-external-tool.sh opencode <prompt-file>` scaffold.

### `claude-code` placeholder

- Keep the documentation hook and prompt-body compatibility notes, but do not treat this as a runnable integration.
- The important things to keep stable once the wrapper exists are:
  - task boundaries
  - acceptance criteria
  - verification commands
  - output format
- Until the wrapper is implemented, selecting `claude-code` should be treated as blocked rather than supported.

## Recommended Practices

- Quality priority mode: prefer single-task prompt bodies.
- Efficiency priority mode: prefer batch execution prompt bodies.
- When adding a third tool, first verify that it supports:
  - submitting a complete prompt
  - consistently returning structured results
  - providing timely responses when interrupted or blocked

Meeting these three criteria makes the tool eligible for integration.

See [tool-wrapper-examples.md](../assets/tool-wrapper-examples.md) for example wrappers.
