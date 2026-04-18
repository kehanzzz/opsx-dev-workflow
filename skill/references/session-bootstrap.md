# Session Bootstrap Anchor

When you have obtained a `change-id` through `openspec-propose` or the optional `openspec-new-change` path, or when a long-running conversation afterwards raises concerns about context drift, perform the steps below before proceeding.

The pre-change exploration phase does not yet have a `change-id`, so it is not required to create any `workflow-state` files. If you finish exploration without entering the change phase, it is normal to leave no state files behind.

Runtime state is stored in the current change directory, not inside the skill repo:

- Recommended path: `openspec/changes/<change-id>/workflow-state/`
- Every file below points to this runtime directory rather than the templates inside the skill repo.

When entering an already created change for the first time, run:

`scripts/init-change-state.sh <change-id> [project-root]`

## Bootstrap Steps

1. Read `openspec/changes/<change-id>/workflow-state/current-workflow-state.md`
2. Read `openspec/changes/<change-id>/workflow-state/current-plan.md`
3. Read `openspec/changes/<change-id>/workflow-state/current-task.md`
4. If external execution or review is involved, also read `openspec/changes/<change-id>/workflow-state/review-checklist.md`

## Mandatory Self-Checks

Before continuing, answer briefly in text:

- What is the current phase?
- What is the current execution mode?
- Which external tool is active?
- What is the current task?
- What is the next allowed action?

If any answer is missing or inconsistent, fix the state files in the current change before continuing implementation.

If you have just finished an upstream skill inside the OpsX workflow, do one more check before continuing: return to the OpsX mainline, then confirm that the next move still matches the current phase and the recorded `next_action` instead of the upstream skill’s default handoff.

Prefer script-driven state updates over manual edits:

- `scripts/start-execution-mode.sh <change-id> <execution-mode> <external-tool> <next-action> <audit-action> [project-root]`
- `scripts/validate-execution-state.sh <change-id> <mode> [project-root]`
- `scripts/update-state-field.sh <change-id> workflow <field> <value> [project-root]`
- `scripts/update-state-field.sh <change-id> plan <field> <value> [project-root]`
- `scripts/update-state-field.sh <change-id> task <field> <value> [project-root]`
- `scripts/set-current-task.sh <change-id> <task-id> <task-goal> <next-action> [project-root]`
- `scripts/finish-task-review.sh <change-id> <review-status> <task-status> <mode> <tool> <review-action> <next-action> [project-root]`
- `scripts/finish-batch-review.sh <change-id> <batch-status> <next-phase> <mode> <tool> <review-action> <next-action> [project-root]`
- `scripts/advance-phase.sh <change-id> <phase> <next-action> [project-root]`
- `scripts/prepare-phase-gate.sh <change-id> <finalization> <execute-action> [project-root]`
- `scripts/enter-approved-phase.sh <change-id> <finalization> <execute-action> [project-root]`
- `scripts/select-verification-strategy.sh <backend-only|frontend-ui|full-stack> [capabilities_csv]`
- `scripts/start-code-review-loop.sh <change-id> [max-rounds] [project-root]`
- `scripts/handle-code-review-result.sh <change-id> <APPROVED|CHANGES_REQUESTED|BLOCKED> <feedback-summary> [project-root]`
- `scripts/continue-code-review-loop.sh <change-id> [project-root]`
- `scripts/start-finalization-pipeline.sh <change-id> [project-root]`
- `scripts/complete-finalization-stage.sh <change-id> <memory-generation|archive|branch-finish> <completed|blocked> [project-root]`
- `scripts/render-memory-generation-prompt.sh <change-id> [project-root] [output-file]`
- `scripts/render-archive-prompt.sh <change-id> [project-root] [output-file]`
- `scripts/render-branch-finish-prompt.sh <change-id> [project-root] [output-file]`
- `scripts/append-audit-log.sh <change-id> <phase> <mode> <tool> <action> <result> <next-action> [project-root]`

## Before Entering Step 5

Confirm the following fields are recorded in `openspec/changes/<change-id>/workflow-state/current-workflow-state.md` at a minimum:

- `current_phase`
- `execution_mode`
- `external_tool`
- `plan_path`
- `next_action`

If you have selected the efficiency priority or quality priority branch, also confirm:

- The external tool has been specified.
- The corresponding prompt body is prepared.
- You know which CLI or equivalent command interface will be invoked.

## Recovery Rules

- As soon as you notice yourself relying on impressions instead of the state files, return to this document.
- Whenever the scope changes, the spec updates, or the plan rewrites, sync the state directory under the current change.
- Without updating the state, a phase transition is not considered complete.
