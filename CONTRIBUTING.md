# Contributing

## Scope

This repository maintains the OpsX workflow skill, its public documentation, and its setup helpers. It does not vendor upstream skills or act as their long-term mirror.

## Before Opening a Pull Request

1. Confirm the proposed change belongs in the workflow layer instead of an upstream dependency.
2. Update related documentation when behavior, structure, or compatibility changes.
3. Run the repository checks listed in `docs/release-checklist.md`.
4. Call out any impact on the current integration baseline for `superpowers` or `OpenSpec`.

## Pull Request Expectations

- Keep changes scoped and reviewable.
- Avoid silent assumptions about upstream dependency behavior.
- Document compatibility impact for Codex, Claude Code, Gemini CLI, and opencode when relevant.
- Do not rewrite the repository narrative around installers or vendored upstream code.

## Reporting Problems

Use the issue templates under `.github/ISSUE_TEMPLATE/` and include the host, dependency versions, and reproduction steps whenever possible.
