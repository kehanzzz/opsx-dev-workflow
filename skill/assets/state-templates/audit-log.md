# Audit Log

Append entries in reverse chronological order, including at least:

- `timestamp`
- `phase`
- `mode`
- `tool`
- `action`
- `result`
- `next_action`

## Example

```text
timestamp: 2026-03-29T10:00:00+08:00
phase: execute-plan
mode: quality-first
tool: opencode
action: run task T-03 via CLI
result: CHANGES_REQUESTED
next_action: refine prompt and rerun T-03
```
