# Skill Verification Log Template

Copy and fill out one of the blocks below for each verification scenario.

## Log Block

```text
Scenario name:
Verification level: Static | Trigger | Process pressure | Regression

Input:

Expected behavior:

Actual behavior:

Result: PASS | FAIL

Deviation:

Impact assessment:
- Does it affect skill triggering?
- Does it affect mode selection?
- Does it affect the references/assets lookup?
- Does it affect execution stability?

Files that require changes:
- SKILL.md
- references/
- assets/

Follow-up actions:
```

## Recommended Usage

- Record each scenario separately; do not mix multiple scenarios in one entry.
- If the result is `FAIL`, clearly categorize whether it is a trigger issue, structural problem, mode selection issue, or a template issue.
- After fixing the problem, add another regression entry to confirm the issue has been closed.
