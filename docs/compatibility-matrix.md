# Compatibility Matrix

| Host | Installation Method | Skill Discovery | External Execution | Script Support | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Codex | Manual, helper script | Partial | Partial | Partial | Partial | Public guidance exists but full host-specific execution still needs end-to-end validation before declaring full support. |
| Claude Code | Manual, helper script | Partial | Experimental | Partial | Experimental | The workflow can be linked into Claude Code, but the host-specific external execution wrapper is still under validation. |
| Gemini CLI | Manual, helper script | Partial | Experimental | Partial | Experimental | Manual installation instructions exist, but the CLI acceleration and discovery flow require additional testing. |
| opencode | Manual, helper script | Partial | Partial | Partial | Partial | The opencode path is the most concrete execution route so far, yet public verification remains pending. |

## Reading This Matrix

Each row lists the conservative status we can claim today. `Supported` is reserved for paths with documented verification artifacts; all current statuses are `Partial` or `Experimental` until we confirm a host end-to-end.

Installation methods mention both manual steps and helper scripts, but hosts must still perform the verification checklist in `docs/installation/verify.md` after linking the workflow.

## Current Recommendation

Treat every host listed here as a validation target. Do not assume feature parity across tools; instead, consult the host-specific installation doc and the compatibility matrix before escalating a release.
