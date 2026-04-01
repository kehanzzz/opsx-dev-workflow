# Upstream Dependencies

OpsX Development Workflow orchestrates upstream skills without vendorizing their implementations. The documentation below names the required, recommended, and optional dependencies along with their source-of-truth repositories.

## Current Integration Baseline

- `superpowers`: <https://github.com/obra/superpowers> — the source for `superpowers:*` workflow and execution helpers.
- `OpenSpec`: <https://github.com/Fission-AI/OpenSpec> — the source for the current `openspec-*` skills and the underlying `openspec` CLI.

These mappings describe the current repository-level expectations. Update the tables before each release if the upstream behavior or availability changes.

## Required Dependencies

| Dependency | Upstream Repository | Role in Workflow | Level | Tested Baseline | Notes |
| --- | --- | --- | --- | --- | --- |
| `openspec-propose` | <https://github.com/Fission-AI/OpenSpec> | Creates the change and the initial proposal/design/tasks artifact set. | Required | Repository-level baseline | Primary OpenSpec entry point for this workflow. |
| `openspec-verify-change` | <https://github.com/Fission-AI/OpenSpec> | Enforces the implementation/spec coherence gate before archive. | Required | Repository-level baseline | Run after repository verification and before archive. |
| `openspec-archive-change` | <https://github.com/Fission-AI/OpenSpec> | Finalizes the change archive and closes the OpenSpec loop. | Required | Repository-level baseline | Final OpenSpec gate before branch finish. |

## Recommended Dependencies

| Dependency | Upstream Repository | Role in Workflow | Level | Tested Baseline | Notes |
| --- | --- | --- | --- | --- | --- |
| `writing-plans` | <https://github.com/obra/superpowers> | Produces executable plans aligned with the spec. | Recommended | Repository-level baseline | Part of the standard plan → execution handoff. |
| `finishing-a-development-branch` | <https://github.com/obra/superpowers> | Closes the change with explicit merge/PR decisions. | Recommended | Repository-level baseline | Final guardrail after verification. |
| `test-driven-development` | <https://github.com/obra/superpowers> | Ensures implementation follows discipline. | Recommended | Repository-level baseline | Reference for every execution task. |
| `subagent-driven-development` | <https://github.com/obra/superpowers> | Preferred execution mode when subagents are available. | Recommended | Repository-level baseline | Enables parallel work within the change. |
| `openspec-explore` | <https://github.com/Fission-AI/OpenSpec> | Keeps requirement exploration inside the same OpenSpec mental model before proposal. | Recommended | Repository-level baseline | Useful when the session starts with problem framing rather than implementation. |

## Optional Paths

| Dependency | Upstream Repository | Role in Workflow | Level | Tested Baseline | Notes |
| --- | --- | --- | --- | --- | --- |
| `openspec-new-change` | <https://github.com/Fission-AI/OpenSpec> | Starts a change with the artifact-first experimental path. | Optional | Repository-level baseline | Use only when you want the experimental OpenSpec artifact workflow. |
| `openspec-continue-change` | <https://github.com/Fission-AI/OpenSpec> | Continues an existing change and advances artifact work. | Optional | Repository-level baseline | Helpful for resuming partially complete OpenSpec changes. |
| `openspec-ff-change` | <https://github.com/Fission-AI/OpenSpec> | Fast-forwards artifact generation in the experimental path. | Optional | Repository-level baseline | Host support may vary. |
| `openspec-apply-change` | <https://github.com/Fission-AI/OpenSpec> | Standard OpenSpec implementation handoff. | Optional | Repository-level baseline | This workflow often uses its own step-5 execution path instead. |
| `openspec-sync-specs` | <https://github.com/Fission-AI/OpenSpec> | Syncs delta specs back into the main spec set before or during archive. | Optional | Repository-level baseline | Useful in repos that keep long-lived OpenSpec spec trees. |

## Versioning Notes

We track the baseline at the repository level and do not pin specific tags or commits. Before public releases, revisit both upstream repositories to confirm the workflows (`superpowers:*` and the current `openspec-*` skills) still behave as expected.
