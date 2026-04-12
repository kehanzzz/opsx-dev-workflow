---
name: opsx-development-workflow
description: Use when a task needs the full OpsX workflow from exploration through change/spec, planning, implementation, verification, archive, and branch finish using OpenSpec and superpowers.
---

# OpsX Development Workflow

## Overview

Drive development through fixed gates: clarify, create the change and spec, write a plan, execute, verify, archive, and finish.

Start by stating: `I am using the opsx-development-workflow skill to drive this end-to-end development workflow.`

## When to Use

- The task must go through the full change / spec / verification / archive loop.
- You need to use both OpenSpec and `superpowers` in the same workflow.
- You do not want to skip the planning, verification, or branch finish gates.

Do not use this skill for:

- Conversations that only answer questions without producing a tangible implementation.
- One-off edits unrelated to the OpsX change workflow.

## Preconditions

- Required OpenSpec skills: `openspec-propose`, `openspec-verify-change`, and `openspec-archive-change`.
- Optional OpenSpec skills: `openspec-explore`, `openspec-new-change`, `openspec-continue-change`, `openspec-ff-change`, `openspec-apply-change`, and `openspec-sync-specs`.
- These OpenSpec skills still rely on the upstream `openspec` CLI under the hood; follow the host's current OpenSpec distribution instead of pinning this repository to older aliases.
- Required superpowers skills: `superpowers:writing-plans`, `superpowers:finishing-a-development-branch`.
- Recommended capability: `superpowers:subagent-driven-development`. If a subagent is unavailable, the external execution branch described in step 5 is still an option.
- Treat `superpowers:test-driven-development` as a mandatory implementation discipline.
- If a required skill is missing, stop immediately and report rather than silently skipping process steps.

## Workflow

After creating or selecting a change through `openspec-propose` or the optional `openspec-new-change` path, read [session-bootstrap.md](references/session-bootstrap.md). It reanchors the current session to the external state stored in the change directory, preventing you from relying solely on conversational memory. It is normal for the pre-change exploration phase to have no `workflow-state` yet.

When this workflow has taken ownership of the task, any upstream skill used inside a phase must hand control back to the OpsX mainline. Do not treat an upstream skill's default "next step" as the workflow's final next step; resume from the current phase definition and the change's `workflow-state/` `next_action`.

### Phase 1: Clarify Requirements and Scope

**Description**: Clarify requirements, constraints, and success criteria before implementation.

**Upstream Skills**:
- Preferred: `openspec-explore`
- Optional support: `superpowers:brainstorming`

**Stop Condition**: If requirements remain ambiguous, do not create a branch, change, or execution plan.

**Checkpoint**: After this phase completes, generate a checkpoint summary and await user approval:

1. Run checkpoint scripts:
   ```bash
   ./scripts/generate-checkpoint-summary.sh explore <change_id>
   ./scripts/update-checkpoint-state.sh <change_id> pending
   ```

2. Present the summary to the user and await input.

3. User actions:
   | Action | Description | State Transition |
   |--------|-------------|------------------|
   | `approve` / `y` | Confirm phase completion | `pending` → `approved`, proceed to Phase 2 |
   | `reject` / `n` | Phase needs revision | `pending` → `rejected`, return to fix and re-submit |
   | `modify <feedback>` | Provide feedback for adjustments | `pending` → `rejected`, record feedback and await revision |

---

### Phase 2: Create and Switch Branches

**Description**: Isolate the development context before writing the spec, code, and verification materials.

**Upstream Skills**:
- Use the branch naming guidance from exploration or change workflows.
- When isolation is required: `superpowers:using-git-worktrees`

**Stop Condition**: Must switch to the branch before writing specs, code, verification material, or archival artifacts.

---

### Phase 3: Create Change and Spec

**Description**: Create the OpenSpec change and specification.

**Upstream Skills**:
- Primary: `openspec-propose`
- Experimental alternative: `openspec-new-change` (if host supports artifact-first workflow)

**Stop Condition**: Do not write implementation plans until the spec accurately reflects the clarified scope.

**Checkpoint**: After this phase completes, generate a checkpoint summary and await user approval:

1. Run checkpoint scripts:
   ```bash
   ./scripts/generate-checkpoint-summary.sh change-and-spec <change_id>
   ./scripts/update-checkpoint-state.sh <change_id> pending
   ```

2. Present the summary to the user and await input.

3. User actions:
   | Action | Description | State Transition |
   |--------|-------------|------------------|
   | `approve` / `y` | Confirm phase completion | `pending` → `approved`, proceed to Phase 4 |
   | `reject` / `n` | Phase needs revision | `pending` → `rejected`, return to fix and re-submit |
   | `modify <feedback>` | Provide feedback for adjustments | `pending` → `rejected`, record feedback and await revision |

---

### Phase 4: Write Execution Plan

**Description**: Write an executable plan based on the confirmed spec.

**Upstream Skills**:
- Required: `superpowers:writing-plans`

**Stop Condition**: The plan must be detailed enough to support execution, verification, and wrap-up.

**Checkpoint**: After this phase completes, generate a checkpoint summary and await user approval:

1. Run checkpoint scripts:
   ```bash
   ./scripts/generate-checkpoint-summary.sh planning <change_id>
   ./scripts/update-checkpoint-state.sh <change_id> pending
   ```

2. Present the summary to the user and await input.

3. User actions:
   | Action | Description | State Transition |
   |--------|-------------|------------------|
   | `approve` / `y` | Confirm phase completion and select execution mode | See Step 4 below |
   | `reject` / `n` | Phase needs revision | `pending` → `rejected`, return to fix and re-submit |
   | `modify <feedback>` | Provide feedback for adjustments | `pending` → `rejected`, record feedback and await revision |

4. **After approve**: Use the Question tool to prompt for execution mode selection:

   **Step 1 - Select execution mode**:
   | Option | Description |
   |--------|-------------|
   | `subagent` | Subagent-driven development (recommended, stays in current session) |
   | `quality` | Quality Priority (external tool, task-by-task review) |
   | `efficiency` | Efficiency Priority (external tool, batch execution) |

   **Step 2 - If quality or efficiency selected**: Prompt for external tool selection:
   | Option | Description |
   |--------|-------------|
   | `opencode` | Use opencode CLI |
   | `claude-code` | Use Claude Code |

   **Update workflow-state**:
   - Set `execution_mode` based on selection: `subagent-driven-development`, `quality-priority`, or `efficiency-priority`
   - If external tool selected (quality/efficiency), set `external_tool` to `opencode` or `claude-code`
   - Use `./scripts/update-state-field.sh <change_id> <field> <value>` to update these fields
   - Proceed to Phase 5 with the chosen execution mode

---

### Phase 5: Execute the Plan

**Description**: Implement the plan under TDD discipline.

**Upstream Skills**:
- Default: `superpowers:test-driven-development`
- Recommended: `superpowers:subagent-driven-development`

**Execution Options**:
- **Subagent-driven development** (recommended): Stay in current session and reuse existing subagent workflows.
- **Efficiency priority**: For clear specs, mechanical implementations; see [execution-modes.md](references/execution-modes.md).
- **Quality priority**: For high-risk, cross-module, or shifting requirements; see [execution-modes.md](references/execution-modes.md).
- **External tool**: If switching to an external agent, confirm whether to use `opencode` or `Claude Code` before invoking. See [external-agent-tools.md](references/external-agent-tools.md).

**Stop Condition**: If the scope changes significantly, return to exploration and spec phases.

**Checkpoint**: After this phase completes, generate a checkpoint summary and await user approval:

1. Run checkpoint scripts:
   ```bash
   ./scripts/generate-checkpoint-summary.sh execution <change_id>
   ./scripts/update-checkpoint-state.sh <change_id> pending
   ```

2. Present the summary to the user and await input.

3. User actions:
   | Action | Description | State Transition |
   |--------|-------------|------------------|
   | `approve` / `y` | Confirm phase completion and select next step | See Step 4 below |
   | `reject` / `n` | Phase needs revision | `pending` → `rejected`, return to fix and re-submit |
   | `modify <feedback>` | Provide feedback for adjustments | `pending` → `rejected`, record feedback and await revision |

4. **After approve**: Use the Question tool to prompt for next step selection:

   **Select next step**:
   | Option | Description | Next Action |
   |--------|-------------|-------------|
   | `verify` | Proceed to verification phase | Invoke `openspec-verify-change` |
   | `review` | Request code review first | Invoke `superpowers:requesting-code-review`, then proceed to Phase 6 after review completes |

    **Proceed based on selection**:
    - If `verify`: Update `next_action` to `openspec-verify-change` and proceed to Phase 6
    - If `review`: Invoke `superpowers:requesting-code-review`, then proceed to Phase 6 after review completes

---

### Phase 5.5: Code Review

**Description**: Perform code review after implementation completes.

**Upstream Skills**:
- Required: `superpowers:requesting-code-review`

**Stop Condition**: Address all review feedback before proceeding to verification.

**Checkpoint**: After this phase completes, generate a checkpoint summary and await user approval:

1. Run checkpoint scripts:
   ```bash
   ./scripts/generate-checkpoint-summary.sh code-review <change_id>
   ./scripts/update-checkpoint-state.sh <change_id> pending
   ```

2. Present the summary to the user and await input.

3. User actions:
   | Action | Description | State Transition |
   |--------|-------------|------------------|
   | `approve` / `y` | Confirm review completion | `pending` → `approved`, proceed to Phase 6 |
   | `reject` / `n` | Review needs more work | `pending` → `rejected`, return to address feedback |
   | `modify <feedback>` | Provide additional feedback | `pending` → `rejected`, record feedback and await revision |

---

### Phase 6: Verify Results

**Description**: Perform repository verification actions and run change verification.

**Integration Testing Strategy**:

Determine the appropriate integration test type based on the scope of changes:

| Change Scope | Primary Test Agent | Secondary Agent | Test Focus |
|-------------|-------------------|-----------------|------------|
| Backend-only changes | `API Tester` | `Reality Checker` | API integration, cross-module tests |
| Frontend/UI changes | `Evidence Collector` | `Reality Checker` | End-to-end (E2E) tests with screenshots |
| Full-stack changes | `API Tester` + `Evidence Collector` | `Reality Checker` | E2E + API integration tests |

**Agent Responsibilities**:

### `API Tester` (Backend Integration)
- Test API endpoints with functional, security, and performance validation
- Validate API response format, status codes, error handling
- Test cross-module integration and data flow
- Check authentication, authorization, rate limiting

### `Evidence Collector` (Frontend E2E)
- Execute end-to-end user journeys with screenshot evidence
- Test responsive design across devices (desktop/tablet/mobile)
- Verify interactive elements (forms, navigation, accordions)
- Default to finding 3-5 issues, require visual proof

### `Reality Checker` (Final Integration)
- Cross-validate all test findings with evidence
- Default to "NEEDS WORK" status
- Stop fantasy approvals without overwhelming proof
- Provide realistic production readiness assessment

**Test Selection Process**:
1. Analyze the diff to identify changed files and modules
2. Classify changes: frontend-only, backend-only, or full-stack
3. Select appropriate test agent(s) from the table above
4. Execute tests and capture evidence in `.sisyphus/evidence/`
5. Run `Reality Checker` for final integration validation

**Upstream Skills**:
- Required: Repository verification + `openspec-verify-change`

**Stop Condition**: Fix failures before proceeding to archive.

**Checkpoint**: After this phase completes, generate a checkpoint summary and await user approval:

1. Run checkpoint scripts:
   ```bash
   ./scripts/generate-checkpoint-summary.sh verification <change_id>
   ./scripts/update-checkpoint-state.sh <change_id> pending
   ```

2. Present the summary to the user and await input.

3. User actions:
   | Action | Description | State Transition |
   |--------|-------------|------------------|
   | `approve` / `y` | Confirm phase completion | `pending` → `approved`, proceed to Phase 7 |
   | `reject` / `n` | Phase needs revision | `pending` → `rejected`, return to fix and re-submit |
   | `modify <feedback>` | Provide feedback for adjustments | `pending` → `rejected`, record feedback and await revision |

---

### Phase 7: Archive Work

**Description**: Archive the change when implementation, spec, and verification states align.

**Upstream Skills**:
- Required: `openspec-archive-change`

**Stop Condition**: Archive only when implementation, spec, and verification states are aligned.

**Checkpoint**: After this phase completes, generate a checkpoint summary and await user approval:

1. Run checkpoint scripts:
   ```bash
   ./scripts/generate-checkpoint-summary.sh archive <change_id>
   ./scripts/update-checkpoint-state.sh <change_id> pending
   ```

2. Present the summary to the user and await input.

3. User actions:
   | Action | Description | State Transition |
   |--------|-------------|------------------|
   | `approve` / `y` | Confirm phase completion | `pending` → `approved`, proceed to Phase 8 |
   | `reject` / `n` | Phase needs revision | `pending` → `rejected`, return to fix and re-submit |
   | `modify <feedback>` | Provide feedback for adjustments | `pending` → `rejected`, record feedback and await revision |

---

### Phase 8: Finish Branch Development

**Description**: Handle final test confirmation, merge/PR decisions, and branch finish.

**Upstream Skills**:
- Required: `superpowers:finishing-a-development-branch`

**Checkpoint**: After this phase completes, generate a checkpoint summary and await user approval:

1. Run checkpoint scripts:
   ```bash
   ./scripts/generate-checkpoint-summary.sh branch-finish <change_id>
   ./scripts/update-checkpoint-state.sh <change_id> pending
   ```

2. Present the summary to the user and await input.

3. User actions:
   | Action | Description | State Transition |
   |--------|-------------|------------------|
   | `approve` / `y` | Confirm workflow complete | `pending` → `approved`, workflow finished |
   | `reject` / `n` | Phase needs revision | `pending` → `rejected`, return to fix and re-submit |
   | `modify <feedback>` | Provide feedback for adjustments | `pending` → `rejected`, record feedback and await revision |

---

See [workflow-reference.md](references/workflow-reference.md) for a full phase reference, stop conditions, and a quick lookup. State templates live in [assets/state-templates/](assets/state-templates), and script entry points are under [scripts/](scripts).

## Execution Principles

- Do not proceed when requirements are vague, the spec conflicts, or the plan has drifted.
- Do not write production code without a failing test.
- Do not archive before verification succeeds.
- Do not skip the branch finish skill and end work prematurely.
- Do not rely solely on session memory to track progress; key state must be written back to the workflow-state directory under the current change.
- Before moving to the next phase, ensure the exit conditions for the current phase are recorded in state or audit logs.

## Common Mistakes

- Starting implementation before the proposal/spec phase has converged.
- Writing a plan before the change and spec exist.
- Treating step 5 execution as a single fixed path instead of selecting a mode first.
- Treating an external agent's success report as verification evidence.
