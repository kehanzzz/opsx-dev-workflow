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

1. Explore: clarify requirements, constraints, and success criteria before implementation; `openspec-explore` is the natural OpenSpec entry, and `superpowers:brainstorming` remains optional support when deeper design work is needed.
2. Create and switch branches: isolate the development context before writing the spec, code, and verification materials; use `superpowers:using-git-worktrees` when isolation is required.
3. OpenSpec change and spec creation: use `openspec-propose` as the primary route. If your host exposes the experimental artifact-first path, `openspec-new-change` is the optional alternative. Do not begin implementation planning before the spec converges.
4. `superpowers:writing-plans`: write an executable plan based on the confirmed spec.
5. Execute the plan: default to `superpowers:test-driven-development`, then choose one of the following execution options:
   - `superpowers:subagent-driven-development`: the recommended path when you want to stay in the current session and reuse existing subagent workflows.
   - Efficiency priority: suitable for clear specs, mechanical implementations, and goals of saving tokens or increasing throughput; see [execution-modes.md](references/execution-modes.md) for details.
   - Quality priority: suitable for high-risk, cross-module, or shifting requirements; see [execution-modes.md](references/execution-modes.md) for details.
   - If you choose the efficiency or quality priority branch, decide on the external tool before detailing the execution mode. Prefer any tool explicitly specified by the user; if none is specified, ask whether to use `opencode` or `Claude Code`—do not assume. After the tool is confirmed, the current agent must proactively invoke the external tool through the CLI or an equivalent command interface instead of stopping at prompt generation. Refer to [external-agent-tools.md](references/external-agent-tools.md) for tool adaptation and reuse prompt templates in [assets/](assets).
6. Verification: perform the repository verification actions required by the change, then run `openspec-verify-change` before archiving.
7. Archive: archive only when implementation, spec, and verification states agree. Use `openspec-archive-change` as the standard path.
8. `superpowers:finishing-a-development-branch`: handle final test confirmation, merge/PR decisions, and branch finish.

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
