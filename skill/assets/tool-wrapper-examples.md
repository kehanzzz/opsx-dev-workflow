# External execution tool wrapper examples

This document is not a conceptual overview but the operating guide for the lead agent.

When step 5 chooses “efficiency-first” or “quality-first,” the lead agent should follow the steps described here to proactively invoke external tools, rather than just generating prompts or staying at the recommendation level.

Unless there is a special reason otherwise, first run `scripts/init-change-state.sh <change-id>`, then enter step 5 via `scripts/start-execution-mode.sh`, sync high-level state with `scripts/advance-phase.sh`, `scripts/set-current-task.sh`, `scripts/finish-task-review.sh`, and `scripts/finish-batch-review.sh`, rerun `scripts/validate-execution-state.sh` before calling external tools, use `scripts/update-state-field.sh` to fill missing fields when needed, and finally go through the unified entry point `scripts/run-external-tool.sh`. This file describes how the wrapper layer should look and what invocation patterns scripts should follow.

The content in `assets/*.md` files is now purely the prompt body and can be read directly without additional headings or code fences.

- Single task body: [quality-task-prompt-body.md](quality-task-prompt-body.md)
- Batch execution body: [efficiency-batch-prompt-body.md](efficiency-batch-prompt-body.md)

## `opencode` wrapper example

Suitable for submitting the complete prompt directly via CLI.

### Quality-first mode

Lead agent standard steps:

1. Invoke `scripts/start-execution-mode.sh <change-id> quality-first opencode "<next-action>" "<audit-action>"`
2. Invoke `scripts/set-current-task.sh` to sync the current task
3. Read and populate the single task prompt body
4. Invoke `scripts/validate-execution-state.sh <change-id> quality-first`
5. Execute `opencode run` via CLI
6. Wait for the external agent to return structured results
7. Enter the current task review
8. Invoke `scripts/finish-task-review.sh` to write back the review conclusion and next action
9. If not accepted, repeat the invocation around the current task

Standard command pattern:

```bash
PROMPT="$(cat assets/quality-task-prompt-body.md)"
opencode run "$PROMPT"
```

### Efficiency-first mode

Lead agent standard steps:

1. Invoke `scripts/start-execution-mode.sh <change-id> efficiency-first opencode "<next-action>" "<audit-action>"`
2. Read and populate the batch execution prompt body
3. Invoke `scripts/validate-execution-state.sh <change-id> efficiency-first`
4. Execute `opencode run` once via CLI
5. Wait for the external agent to finish the entire batch of tasks
6. Perform a one-time acceptance once results arrive
7. Invoke `scripts/finish-batch-review.sh` to write back the batch acceptance conclusion and the next stage
8. If the results are unsatisfactory, trigger another external run or return to the planning phase

Standard command pattern:

```bash
PROMPT="$(cat assets/efficiency-batch-prompt-body.md)"
opencode run "$PROMPT"
```

## `Claude Code` wrapper example

Suitable for treating the same prompt body as the task description, a sub-agent input, or the description for an external execution session.

### Quality-first mode

```text
Task title: Execute a single task
Lead agent steps:
  1. Read and populate the single task prompt body
  2. Proactively create a Claude Code task or session
  3. Submit the prompt body as the task input
  4. Wait for the response before performing the current task review

Task input:
  Read assets/quality-task-prompt-body.md
  Populate change_id, spec_path, plan_path, task_id, acceptance_criteria, allowed_files, validation commands
  Submit to the Claude Code sub-agent following the original structure
```

### Efficiency-first mode

```text
Task title: Execute the entire plan in batch
Lead agent steps:
  1. Read and populate the batch execution prompt body
  2. Proactively create a Claude Code task or session
  3. Submit the full prompt body
  4. Wait for the batch completion results
  5. Return to the lead agent for a one-time acceptance

Task input:
  Read assets/efficiency-batch-prompt-body.md
  Populate spec_summary, implementation_scope, planned task list, validation commands
  Submit to the Claude Code sub-agent following the original structure
```

## Usage rules

- The lead agent must actually perform the wrapper layer actions and not just display these examples.
- Only replace the wrapper layer without altering the section structure of the prompt bodies.
- When switching tools, retain the same set of:
  - task boundaries
  - acceptance criteria
  - validation commands
  - output format
- Do not integrate a tool that cannot reliably return structured results into this skill.
