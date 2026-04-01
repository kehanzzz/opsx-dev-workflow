# External agent execution example

The OpsX workflow can delegate to an external agent after the minimal usage example completes. This file captures the entry point so you can wire it into host-specific orchestration.

## Invocation

```
<host> skill run examples/external-agent-execution.md
```

The external agent should echo a short plan that references the same spec/plan boundaries described in [docs/installation/verify.md](../docs/installation/verify.md). Use the host-specific CLI name in place of `<host>`.
