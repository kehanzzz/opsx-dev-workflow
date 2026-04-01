# Issue Labels

| Label | Use |
| --- | --- |
| `bug` | Confirmed defects or regressions |
| `docs` | README, installation, troubleshooting, examples |
| `release` | Release prep, packaging, metadata, versioning |
| `installation` | Host-specific setup or environment issues |
| `compatibility` | Host support gaps across Codex, Claude Code, Gemini CLI, and opencode |
| `upstream` | Changes caused by OpenSpec or superpowers updates |
| `workflow` | Stage logic, state flow, verification, archive rules |
| `enhancement` | Non-breaking improvements to the workflow or docs |
| `good first issue` | Safe starting points for new contributors |
| `help wanted` | Work that is open for community contribution |

## Minimal Starter Set

If you want to keep it lean, start with:

- `bug`
- `docs`
- `installation`
- `compatibility`
- `upstream`
- `enhancement`

## Optional Helper

This repository also includes:

- label data: [../.github/labels.tsv](../.github/labels.tsv)
- sync script: [../scripts/setup-github-labels.sh](../scripts/setup-github-labels.sh)

If you use GitHub CLI, you can initialize or update labels with:

```bash
./scripts/setup-github-labels.sh <owner/repo>
```
