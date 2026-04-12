# Phase Reference

## Phase Quick Reference

| Phase | Skill | Deliverable |
|------|------|------|
| Session bootstrap | [session-bootstrap.md](session-bootstrap.md) | The current phase, mode, task, and next action for the change |
| Requirement exploration | `openspec-explore` + explicit exploration | Clarified scope, constraints, and success criteria |
| Context setup | Local branch or `superpowers:using-git-worktrees` | Isolated development context |
| Change creation | `openspec-propose` or `openspec-new-change` | OpenSpec change and spec |
| Plan writing | `superpowers:writing-plans` | An executable task plan |
| Implementation | Step 5 execution modes | Implementation under TDD discipline |
| Code review | `superpowers:requesting-code-review` | Reviewed implementation with resolved feedback |
| Verification | `openspec-verify-change` | Verifiable validation results |
| Archiving | `openspec-archive-change` | Complete archival materials |
| Branch finish | `superpowers:finishing-a-development-branch` | Merge, PR, or cleanup decisions |

## Phase Rules

### 0. Session Bootstrap

- The pre-change exploration phase does not require a `workflow-state/` directory.
- After obtaining a `change-id`, read [session-bootstrap.md](session-bootstrap.md).
- Persist key state to the current change’s `workflow-state/`; don’t rely only on session memory.
- If an upstream skill is invoked inside the workflow, return to the OpsX mainline afterwards and continue from the recorded phase and `next_action`.
- If the current phase, mode, or task descriptions conflict, fix the state before proceeding.

### 1. Clarify Requirements and Scope

- Required: explicit exploration before implementation
- Preferred OpenSpec path: `openspec-explore`
- Optional support: `superpowers:brainstorming`
- This phase is still pre-change. Use a session-level summary checkpoint instead of change-bound checkpoint scripts.
- If requirements remain ambiguous, do not create a branch, change, or execution plan.

### 2. Create and Switch Branches

- Use the branch naming guidance from exploration or change workflows.
- Switch to the branch before writing specs, code, verification material, or archival artifacts.
- When isolation is needed, use `superpowers:using-git-worktrees`.

### 3. Create Change and Spec

- Prefer `openspec-propose`.
- If your host supports the experimental artifact-first workflow, `openspec-new-change` is an optional alternative.
- Once you have a `change-id`, initialize that change’s `workflow-state/` immediately.
- Do not write implementation plans until the spec accurately reflects the clarified scope.

### 4. Write the Execution Plan

- Required: `superpowers:writing-plans`
- The plan must be based on the confirmed spec.
- The plan must be detailed enough to support execution, verification, and wrap-up.
- After `superpowers:writing-plans` completes, return to the OpsX mainline instead of treating that skill’s default handoff as the workflow’s final next step.

### 5. Execute the Plan

- Default to `superpowers:test-driven-development`.
- Prefer `superpowers:subagent-driven-development`.
- If you switch to an external execution agent, choose between efficiency priority and quality priority.
- `opencode` is the only runnable external wrapper today. `claude-code` remains a documented placeholder until its wrapper exists.
- Before invoking an external tool, write `execution_mode`, `external_tool`, and `next_action` to `workflow-state/current-workflow-state.md` in the current change.
- Record external invocations, task reviews, and acceptance conclusions in `workflow-state/audit-log.md`.
- If the scope changes significantly, return to the exploration and spec phases.
- For details on modes, templates, and reviews, see [execution-modes.md](execution-modes.md).

### 5.5 Code Review

- Required: `superpowers:requesting-code-review`
- Enter this phase only when Step 5 explicitly chooses `review`.
- Review feedback must be addressed before moving to verification.

### 6. Verify Results

- Required: repository verification plus `openspec-verify-change`
- `API Tester`, `Evidence Collector`, and `Reality Checker` are optional accelerators rather than guaranteed dependencies.
- Resolve the verification path first with `scripts/select-verification-strategy.sh`; if capabilities are missing, fall back to repository-native verification plus `openspec-verify-change`.
- Fix failures before proceeding.

### 7. Archive Work

- Required: `openspec-archive-change`
- Before invoking archival, enter `archive-approval` via `scripts/prepare-phase-gate.sh` and wait for approval.
- Only after approval should the workflow enter `archive` via `scripts/enter-approved-phase.sh` and run archival.
- Archive only when implementation, spec, and verification states are aligned.

### 8. Finish Branch Development

- Required: `superpowers:finishing-a-development-branch`
- Before invoking branch finish actions, enter `branch-finish-approval` via `scripts/prepare-phase-gate.sh` and wait for approval.
- Only after approval should the workflow enter `branch-finish` via `scripts/enter-approved-phase.sh`.
- That skill handles final test confirmation, merge or PR decisions, cleanup, and branch finish.

## Stop Conditions

- Key requirements remain ambiguous after exploration.
- The spec is missing or conflicts with the confirmed scope.
- The plan is inconsistent with the spec.
- The current change’s `workflow-state/` files disagree about phase, plan, or task.
- Verification fails.
- Archiving is requested before verification passes.

If any stop condition occurs, identify the earliest failing phase and restart from that phase.

## Common Mistakes

- Starting implementation before the proposal/spec phase converges.
- Writing an implementation plan before creating the change and spec.
- Treating an upstream skill’s default “next step” as the workflow’s final next step.
- Skipping `superpowers:test-driven-development` during the execution phase.
- Treating an external agent’s success report as verification evidence.
- Running `openspec-archive-change` before `openspec-verify-change`.
- Ending branch development without invoking `superpowers:finishing-a-development-branch`.

## Checkpoint Mechanism

Checkpoints are automatic pause points that occur after major review gates. They provide structured review opportunities and ensure work progresses through proper validation gates.

### Purpose

- Ensure each phase completes successfully before advancing
- Provide user visibility into workflow progress
- Enable course correction before accumulating drift
- Create explicit decision points for approval/rejection

### Trigger Timing

Checkpoints are triggered automatically after these phases:

- Phase 1: After requirement exploration completes, using a session-level summary rather than change-bound state scripts
- Phase 3: After change and spec creation completes
- Phase 4: After execution plan writing completes
- Phase 5: After implementation execution completes
- Phase 5.5: After code review completes
- Phase 6: After verification completes
- Phase 7: Before archival executes, using the `archive-approval` gate
- Phase 8: Before branch finish executes, using the `branch-finish-approval` gate

### Summary Format

Each change-bound checkpoint now generates a Markdown summary from the current `workflow-state/` and persists the rendered body to `workflow-state/checkpoint-summary.md`. The `checkpoint_summary` field stores that file path.

The generated summary should reflect the recorded state whenever available:

- current phase and next allowed action from `current-workflow-state.md`
- plan summary and task counts from `current-plan.md`
- current task anchor and review status from `current-task.md`
- fallback defaults only when state files do not yet exist or lack relevant fields

The rendered Markdown body contains:

```
## Checkpoint Summary - Phase [N]: [Phase Name]

### Completed Items
- [List of deliverables completed in this phase]

### Next Action
- [What happens if approved]

### Blockers/Issues (if any)
- [Current blockers or pending decisions]

### User Actions Required
- [What user needs to do]
```

### User Operations

At each checkpoint, the user can choose one of three actions:

| Action | Description | State Transition |
|--------|-------------|------------------|
| `approve` | Confirm phase completion and proceed to next phase | `pending` → `approved` |
| `reject` | Indicate phase output needs revision | `pending` → `rejected` |
| `modify` | Provide feedback requiring adjustments | `pending` → `rejected` |

### State Transition

```
[Phase N Complete] → Checkpoint Created → State: pending
                                              ↓
                        ┌─────────────────────┼─────────────────────┐
                        ↓                     ↓                     ↓
                   [approve]              [reject]             [modify]
                        ↓                     ↓                     ↓
                   approved              rejected               rejected
                        ↓                     ↓                     ↓
                [Proceed to            [Return to           [Provide feedback]
                 Phase N+1]            Phase N to fix]     [Record feedback and revise]
```

### Usage Notes

- Phase 2 is intentionally excluded because branch setup is a mechanical isolation step
- For change-bound checkpoints, prefer `./scripts/generate-checkpoint-summary.sh <phase> <change_id> | ./scripts/update-checkpoint-state.sh <change_id> pending`
- For irreversible phases, first call `./scripts/prepare-phase-gate.sh`, then checkpoint, then `./scripts/enter-approved-phase.sh` after approval.
- The `rejected` state requires re-executing the current phase before proceeding
- The `modify` action records feedback, then routes back through the current phase for revision
- Phase 0 (Session Bootstrap) does not generate a checkpoint as it precedes formal change tracking
