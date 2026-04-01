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
- If the external agent is used but the user has not specified a tool, confirm whether to use `opencode` or `Claude Code`.
- Before invoking an external tool, write `execution_mode`, `external_tool`, and `next_action` to `workflow-state/current-workflow-state.md` in the current change.
- Record external invocations, task reviews, and acceptance conclusions in `workflow-state/audit-log.md`.
- If the scope changes significantly, return to the exploration and spec phases.
- For details on modes, templates, and reviews, see [execution-modes.md](execution-modes.md).

### 6. Verify Results

- Required: repository verification plus `openspec-verify-change`
- Fix failures before proceeding.

### 7. Archive Work

- Required: `openspec-archive-change`
- Archive only when implementation, spec, and verification states are aligned.

### 8. Finish Branch Development

- Required: `superpowers:finishing-a-development-branch`
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
