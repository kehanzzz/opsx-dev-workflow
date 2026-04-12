# Step 5 Execution Mode Reference

## Applicability

This document does not define the default execution discipline for Step 5.

Step 5 defaults to `superpowers:test-driven-development` with a preference for `superpowers:subagent-driven-development`.

Read this document only if Step 5 explicitly branches into one of the following external execution paths:

- **Efficiency priority**
- **Quality priority**

## Mode Selection

When Step 5 will use an external agent, choose between the two modes based on the goals:

- **Quality priority mode**
  - Best for high-risk changes, cross-module updates, shifting requirements, or when low-cost models tend to drift.
  - Characteristics: execute and review per task to catch deviations early.
- **Efficiency priority mode**
  - Best for clear specs, mechanical implementations, tightly coupled tasks, and goals centered on saving tokens and speeding up delivery.
  - Characteristics: deliver a single complete plan, let a low-cost model sequentially finish all tasks, and perform a single final acceptance.

Prioritize these signals:

- Efficiency priority is more appropriate when the spec is stable, tasks are mostly mechanical, review splitting adds little value, and time/cost are the priority.
- Quality priority is more appropriate when architectural judgment, boundary sensitivity, regression risk, or requirement volatility are present.

Regardless of the chosen mode, the current agent must personally initiate the external call:

- Invoke the external tool through the CLI or an equivalent command interface.
- Do not stop at prompt creation, examples, or requests for the user to run the tool themselves.
- If the environment cannot call the external tool, explicitly report the blockage rather than pretending Step 5 completed.
- Before invoking, update `workflow-state/current-workflow-state.md` in the current change; after invoking, record the results and conclusions in `workflow-state/audit-log.md`.
- Entering Step 5 should usually start with `scripts/start-execution-mode.sh`.
- Prefer running `scripts/validate-execution-state.sh` for lightweight safety checks before invoking the tool.
- Reuse scripts such as `scripts/init-change-state.sh`, `scripts/start-execution-mode.sh`, `scripts/advance-phase.sh`, `scripts/set-current-task.sh`, `scripts/finish-task-review.sh`, `scripts/finish-batch-review.sh`, `scripts/update-state-field.sh`, `scripts/run-external-tool.sh`, `scripts/review-result.sh`, and `scripts/append-audit-log.sh`.

## Quality-first Mode

Flow:

1. The current agent extracts the context for a single task from the confirmed plan.
2. The current agent drafts prompts for that task.
3. The current agent invokes an external agent to execute exactly one task at a time through the CLI or an equivalent command interface.
4. The current agent reviews the task implementation, verification results, and plan alignment.
5. If the review fails, continue refining the current task; once approved, move to the next task.

Recommended supporting actions:

- Call `scripts/start-execution-mode.sh` first to record the mode and tool.
- Update `workflow-state/current-task.md` before invoking the task.
- Reference `workflow-state/review-checklist.md` during the review.
- Record the review outcome in `workflow-state/audit-log.md`.
- Prefer scripted state updates instead of manual field edits.
- When entering a task, use `scripts/set-current-task.sh` rather than editing `task_id` and `current_task_id` separately.
- After review, call `scripts/finish-task-review.sh` instead of leaving only natural-language conclusions.

### Quality-first Prompt Template

Reusable template: [quality-task-prompt-body.md](../assets/quality-task-prompt-body.md)

For tool-wrapping examples, see [external-agent-tools.md](external-agent-tools.md).

Minimum required fields:

- `task_id`
- `task_goal`
- `acceptance_criteria`
- `allowed_files`
- `red_test_cmd`
- `green_test_cmd`
- `regression_cmd`
- `STATUS` output format

### Quality-first Review Checklist

The current agent must at least verify:

- No out-of-scope changes were made.
- `RED/GREEN/REGRESSION` steps were genuinely run.
- Acceptance criteria are covered.
- Verification commands actually executed.
- The task still requires further work.

Suggested steps:

1. Master review: compare against the plan, spec, and the task's acceptance criteria for omissions, overdelivery, or deviations.
2. Evidence review: do not rely solely on the external agent's report; rerun key commands if needed.
3. For complex tasks, consider invoking `superpowers:requesting-code-review`.
4. If review feedback arrives, treat it with `superpowers:receiving-code-review` to decide whether to fix or treat it as technical rejection.
5. Before declaring the task complete, obey `superpowers:verification-before-completion`.

Explicitly record review outcomes as:

- `APPROVED`
- `CHANGES_REQUESTED`
- `BLOCKED`

Only `APPROVED` allows progression to the next task.

Close reviews with:

- `APPROVED`: mark `task_status` as complete and set `next_action` toward the next task or final acceptance.
- `CHANGES_REQUESTED`: stay on the current task and set `next_action` toward fixes or rerunning verification.
- `BLOCKED`: state the blockage reason and set `next_action` toward resolution steps.

## Efficiency-first Mode

Flow:

1. The current agent delivers the full plan, spec summary, global constraints, verification commands, and response format in one go.
2. The current agent triggers a single batch execution via CLI or an equivalent command interface, letting an external agent complete all tasks sequentially.
3. Interrupt only if blockers, scope conflicts, or spec gaps appear.
4. After everything finishes, the current agent performs a single acceptance pass.

Responsibilities of the current agent:

- Ensure the plan is clear enough before starting.
- Run `scripts/start-execution-mode.sh` to record the efficiency priority mode.
- Actively execute external tool commands instead of asking the user to do so.
- Define allowed directories, forbidden change areas, and mandatory verification commands up front.
- Perform a final check that plan coverage, scope creep, critical tests, and overall regression results are accounted for.
- Before declaring the batch complete, still obey `superpowers:verification-before-completion`.
- Before batch execution, record the overall scope and allowed-modify areas in `workflow-state/current-workflow-state.md`.
- After the batch finishes, write the final acceptance decision to `workflow-state/audit-log.md`.
- Prefer `scripts/advance-phase.sh` when switching phases.
- After final acceptance, prefer `scripts/finish-batch-review.sh`.

Whether to request `superpowers:requesting-code-review` depends on complexity; if the final review returns issues, handle them with `superpowers:receiving-code-review`.

Standardized batch closure statuses:

- `APPROVED`: move to `verify` or the equivalent next phase and set `next_action` to `openspec-verify-change`.
- `CHANGES_REQUESTED`: stay or return to `execute-plan`, pointing `next_action` to batch fixes.
- `BLOCKED`: move to the closest blocking phase and define actions to unblock.

Reusable template: [efficiency-batch-prompt-body.md](../assets/efficiency-batch-prompt-body.md)

Minimum required fields:

- `change_id`
- `spec_summary`
- `implementation_scope`
- Plan task list
- `final_regression_cmds`
- `STATUS` output format
