# Review Checklist

After receiving external execution results, check at least the following items:

- Whether the work still falls within the plan and spec boundaries
- Whether any unauthorized files were modified
- Whether the RED -> GREEN -> REGRESSION cycle was actually experienced
- Whether the critical validation commands were executed and reported
- Whether any unexplained failures, skips, or risks remain
- Whether the result should be marked as `APPROVED`, `CHANGES_REQUESTED`, or `BLOCKED`

For high-risk tasks, also check:

- Whether `superpowers:requesting-code-review` needs to be invoked
- Whether key commands need to be rerun
- Whether the plan or spec phase needs to be revisited
