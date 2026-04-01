# Troubleshooting

## Common Problems

### Missing upstream dependencies
If the workflow loads but stalls before proposal/spec creation or cannot progress through the planned stages, double-check that the required OpenSpec skills (`openspec-propose`, `openspec-verify-change`, `openspec-archive-change`) and recommended `superpowers:*` helpers are available in the host. Refer to `docs/upstream-dependencies.md` for the current baseline.

### Wrong local skill directory
Hosts discover skills from their configured skill directories. Ensure `skill/` is linked or copied into the directory you actually use for Codex, Claude Code, Gemini CLI, or opencode; referencing an old `skills/` path causes discovery failures even though everything else is correct.

### Missing command-line dependencies
The helper scripts assume `git`, `bash`, `python3`, and `rg` are available. Run `./scripts/check-prerequisites.sh` before concluding an install is broken. If the script fails, install those tools or adjust the PATH before retrying.

### Host loads the workflow but external execution is incomplete
The workflow layer may be present, yet a host-specific external execution path (step 5) still needs validation. Revisit the host-specific `docs/installation/<host>.md`, double-check the `docs/compatibility-matrix.md` entry, and confirm the `workflow-state/audit-log.md` notes the chosen execution mode.

### Verification checklist not completed
Before archiving or finishing the branch, make sure you have completed `docs/installation/verify.md`. Failed or skipped verification should be documented in `workflow-state/audit-log.md` and trigger a revisit of the earlier stage (execution, planning, or spec).

### Public docs still referencing old layout
If you encounter documentation that mentions a top-level `skills/` folder, consider it stale. The public installation unit is `skill/`, and every doc should restate the upstream repo origins to avoid implying vendoring.
