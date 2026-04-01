# Skill Verification Plan

## Objectives

Validate that this skill meets the following requirements:

- It is triggered in the correct scenarios.
- The main `SKILL.md` stays concise and does not duplicate heavy rules.
- `references/` and `assets/` maintain a clear and usable separation.
- Step 5’s dual modes and multi-tool adaptations work reliably.
- After long conversations or interruptions, agents can recover discipline through the current change’s `workflow-state/` and the scripts.

## Verification Levels

Execute in order from lowest to highest cost:

1. Static verification
2. Trigger verification
3. Process stress verification
4. Regression verification

## 1. Static Verification

### Checklist

- `description` should explain “when to use” the skill without describing procedural details.
- The main `SKILL.md` should only store entry information and avoid repeating heavyweight rules.
- `references/` should cover Step 5 modes, tool adaptation, phase rules, and verification plans.
- `assets/` should only hold prompt bodies or wrapper examples—not workflow rules.
- All links must be relative.
- The main skill should clearly guide agents to the appropriate reference file.
- Fields in `assets/state-templates/` and runtime `workflow-state/` must be sufficient to recover the current phase, mode, and task.
- `scripts/` must provide a consistent entry point instead of merely concept descriptions.
- State field updates and audit-log appends must be executable via scripts.
- Task and phase transitions should rely on higher-level scripts to avoid unsynchronized fields across files.
- There must be a dedicated entry script for Step 5 to keep execution mode, tool, and audit logs aligned.
- There must be a dedicated review closure script so review conclusions are persisted.
- The efficiency priority mode must have batch-acceptance closure scripts so acceptance is not just verbal.
- A lightweight validation script must exist before external invocation to catch the most common missing state.

### Pass Criteria

- The main `SKILL.md` remains concise.
- Key rules are not confined to a single `assets/` file.
- There are no broken links or absolute paths.

## 2. Trigger Verification

### Should-Trigger Scenarios

1. “Help me drive a requirement through the OpsX workflow from explore to archive.”
2. “I already have a change/spec and need to write a superpowers plan and execute it.”
3. “I want to use an external agent to execute the plan, and then you verify.”
4. “I plan to use Claude Code or opencode for Step 5 execution.”

### Should-Not-Trigger Scenarios

1. “Explain this code snippet for me.”
2. “Write a shell command for me.”
3. “Fix a local typo without going through the change workflow.”

### Observations

- The should-trigger scenarios match this skill.
- The should-not-trigger scenarios do not fire this skill.
- When `Claude Code` or `opencode` is mentioned, the agent drills into the tool-adaptation reference rather than rewriting the workflow.

## 3. Process Stress Verification

### Scenario A: Quality Priority Mode

Input characteristics:

- High risk
- Cross-file
- Elevated regression risk

Expectations:

- The agent selects quality priority mode.
- The agent reads `references/execution-modes.md`.
- The agent uses a single-task prompt body.
- Task-by-task reviews are preserved.

### Scenario B: Efficiency Priority Mode

Input characteristics:

- Clear spec
- Mechanical implementation
- Highly coupled tasks

Expectations:

- The agent selects efficiency priority mode.
- The agent actively invokes the external tool via CLI or an equivalent interface.
- The agent delivers a complete plan in one go.
- The primary agent’s role converges on the final acceptance.
- Key state is written to the current change’s `workflow-state/current-workflow-state.md`.

### Scenario C: Tool Switch

Input characteristics:

- The user explicitly requests not to use `opencode`.
- The user switches to `Claude Code`.

Expectations:

- The agent reads `references/external-agent-tools.md`.
- The same prompt body is reused.
- Only the wrapper layer changes; the core workflow remains intact.
- The primary agent still initiates the tool call instead of merely outputting guidance.

### Scenario E: Tool Not Specified

Input characteristics:

- The user requests an external execution agent.
- The user does not specify whether to use `opencode` or `Claude Code`.

Expectations:

- Before entering external execution, the agent confirms which tool to use.
- The agent does not assume a default tool.
- Only after confirming the tool does the agent proceed into the efficiency or quality priority branches.

### Scenario F: Context Drift Recovery

Input characteristics:

- A long conversation continues after a pause.
- The current session wavers about “which step we are on.”

Expectations:

- The agent returns to `references/session-bootstrap.md`.
- The agent rereads the current change’s `workflow-state/` files.
- Implementation does not continue based on memory alone.

### Scenario D: Boundary Conflict

Input characteristics:

- The spec is incomplete.
- The plan is unclear.

Expectations:

- The agent stays at the prerequisite gate.
- The agent does not proceed directly to Step 5.

## 4. Regression Verification

After every skill change, rerun at least the following scenarios:

1. A full OpsX workflow task to ensure the skill triggers.
2. A normal coding request to ensure the skill does not trigger incorrectly.
3. A high-risk task to ensure quality priority mode is chosen.
4. A low-risk batch task to ensure efficiency priority mode is chosen.
5. Specify `Claude Code` to ensure the tool-adaptation description is referenced.
6. Leave the external tool unspecified to make sure the agent first asks the tool question.
7. Simulate context drift to confirm the agent recovers via the current change’s `workflow-state/`.

## Execution Record Template

Record each scenario using the following format:

```text
Scenario name:
Input:
Expected behavior:
Actual behavior:
Result: PASS | FAIL
Deviation:
Files that require changes:
```

## Suggested Passing Criteria

- All trigger verification scenarios behave as expected.
- Stress scenarios pass at least 4 out of 4.
- At least one `opencode` scenario and one `Claude Code` scenario pass.
- No structural issues prevent the main skill from directing agents to the references.
