# Design Principles

## Workflow First
OpsX Development Workflow exists to expose every stage—explore, spec, planning, execution, verification, archive, and branch finish—as a deliberate handoff, not as a single prompt or glue layer.

## Upstream Dependencies Stay External
`superpowers:*` comes from <https://github.com/obra/superpowers>, and OpenSpec comes from <https://github.com/Fission-AI/OpenSpec>. This repository only documents how to use them together and does not copy their code.

## Documentation First, Scripts Second
Installation guidance is primarily manual, with helper scripts as optional accelerators; host-specific details should live in the docs, not in the scripts.

## Verification Before Completion
Every install or workflow change includes explicit verification instructions that map to `openspec-verify-change` and `superpowers:test-driven-development`; do not archive or finish a branch until verification artifacts are recorded in `workflow-state/`.

## Host-aware, Tiered Support
The workflow targets Codex, Claude Code, Gemini CLI, and opencode, but the public guidance differentiates `Supported`, `Partial`, and `Experimental` statuses so users understand which host paths have been validated.

## Transparent State and Audit
State tracking is not optional—the workflow records entries in `workflow-state/current-workflow-state.md`, `audit-log.md`, and the plan artefacts so reviewers can trace which host, tool, or external execution mode was used in each handoff.
