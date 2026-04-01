# GitHub Launch Runbook

This document is not a design note. It is the operating order to follow on launch day.

## 1. Finish the repository surface

Fill in the following on the GitHub repository page:

- Description: use the recommended copy in [repository-metadata.md](repository-metadata.md)
- Topics: pick 8 to 12 from [repository-metadata.md](repository-metadata.md)
- README: confirm the current version is the default landing page
- License: confirm the repository license is visible

Set the About section first, then publish the release.

## 2. Create the base labels

Create the minimal set first:

- `bug`
- `docs`
- `installation`
- `compatibility`
- `upstream`
- `enhancement`

If you want the full set immediately, add:

- `release`
- `workflow`
- `good first issue`
- `help wanted`

See [issue-labels.md](issue-labels.md) for label definitions.

If GitHub CLI is already installed and authenticated, you can also run:

```bash
./scripts/setup-github-labels.sh <owner/repo>
```

## 3. Check the public doc entry points

Open these entry points manually before release:

- [README.md](../README.md)
- [docs/installation/overview.md](installation/overview.md)
- [docs/upstream-dependencies.md](upstream-dependencies.md)
- [docs/compatibility-matrix.md](compatibility-matrix.md)
- [docs/troubleshooting.md](troubleshooting.md)

Check two things:

- the links are still valid
- naming is already unified to `openspec-*`

## 4. Run pre-release checks

Run these from the repository root:

```bash
bash -n scripts/*.sh skill/scripts/*.sh
./scripts/check-prerequisites.sh
./scripts/verify-install.sh
```

Do not publish a release if these checks fail.

If you plan to use the label sync helper, also confirm that `gh` is installed and `gh auth login` has already been completed.

## 5. Create the first release

Recommended:

- Tag: `v0.1.0`
- Title: `v0.1.0: Initial public release`

Copy the body from [first-release.md](first-release.md), then adjust it to match the validation state at release time.

## 6. Watch the first round of feedback

After launch, watch these categories first:

- installation issues
- host compatibility issues
- misunderstanding of the workflow positioning
- misunderstanding of the upstream dependency model

These signals usually determine whether README and installation docs need another tightening pass.

## 7. Recommended post-launch follow-up

If the first release goes smoothly, prioritize the next round in this order:

1. Add one end-to-end validation record each for Codex and opencode
2. Update conservative compatibility statuses when evidence is available
3. Use real issues to tighten README and troubleshooting
