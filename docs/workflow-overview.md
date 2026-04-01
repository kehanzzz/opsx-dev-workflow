# Workflow Overview

OpsX Development Workflow ties discovery, specification, planning, execution, verification, archive, and branch finish into a single, auditable narrative so multi-agent sessions never leave important decisions only in chat history.

Every stage records its outputs inside the change's `workflow-state/` directory such as `current-workflow-state.md` and `audit-log.md`, so future agents, reviewers, and hosts can rehydrate context from concrete files.

## Stage 1: Explore

Requirement exploration happens before implementation and should be captured into the proposal/spec path rather than left only in chat history. `openspec-explore` is the most direct OpenSpec entry for this stage.

## Stage 2: Branch Setup

Establish a dedicated branch or use `superpowers:using-git-worktrees` to isolate the change before touching spec, plan, or code so the workspace stays clean.

## Stage 3: Change and Spec Creation

Create the change through `openspec-propose` and document the scope in the spec before writing the plan. If your host exposes the experimental artifact-first path, `openspec-new-change` is an optional compatibility route.

## Stage 4: Planning

`superpowers:writing-plans` turns the spec into actionable tasks with clear dependencies, reviewers, and success criteria. Each task should reference the spec and its verification steps.

## Stage 5: Execution

Implementation follows `superpowers:test-driven-development`. Prefer `superpowers:subagent-driven-development`; if an external agent or helper is needed, write the chosen execution mode into the workflow state.

## Stage 6: Verification

Verification combines repository-specific checks with `openspec-verify-change` so the change is both technically verified and structurally valid before archive. Any failing check reopens the relevant previous stage and stays logged in the audit trail.

## Stage 7: Archive

Use `openspec-archive-change` as the standard archive path. Archiving should only happen after implementation and validation are complete.

## Stage 8: Branch Finish

`superpowers:finishing-a-development-branch` closes out the branch, decides between merge, PR, or manual handoff, and leaves a final note about what was verified.

### State and Audit Tracking

Each stage writes `workflow-state/current-workflow-state.md`, `workflow-state/audit-log.md`, and any execution notes so reviewers never have to guess which host or tool was used.

Upstream references: <https://github.com/obra/superpowers>, <https://github.com/Fission-AI/OpenSpec>. This repository documents how to orchestrate those toolkits without vendorizing their source code.
