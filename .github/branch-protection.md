# Branch Protection Configuration

This document describes the branch protection rules that should be configured in GitHub Settings to enforce the release process.

## Configuration Steps

Navigate to: **Settings → Branches → Branch protection rules**

### Rule 1: Protect `master` branch

Create a branch protection rule for `master` with the following settings:

**Branch name pattern:** `master`

**Protect matching branches:**
- ☑ Require a pull request before merging
  - ☑ Require approvals: 0 (approvals not needed, workflow handles merging)
  - ☑ Dismiss stale pull request approvals when new commits are pushed
  - ☐ Require review from Code Owners (optional)
  - ☑ Restrict who can dismiss pull request reviews
  - ☐ Allow specified actors to bypass required pull requests (leave empty)
  - ☑ Require approval of the most recent reviewable push

- ☑ Require status checks to pass before merging
  - ☑ Require branches to be up to date before merging
  - **Required status checks:** `test` (from test-pr.yaml workflow)

- ☑ Require conversation resolution before merging

- ☑ Require signed commits (optional, recommended)

- ☑ Require linear history

- ☐ Require merge queue (not needed)

- ☑ Require deployments to succeed before merging (optional)

- ☑ Lock branch (prevent all pushes except from workflows)
  - This prevents manual merges via UI
  - Only the `release.yaml` workflow can merge to master

- ☑ Do not allow bypassing the above settings
  - This ensures even admins must use `/release` command

- ☑ Restrict who can push to matching branches
  - Add: `github-actions[bot]` (allows workflows to push)
  - Do not add any users (prevents manual pushes)

### Rule 2: Protect `dev` branch

Create a branch protection rule for `dev` with the following settings:

**Branch name pattern:** `dev`

**Protect matching branches:**
- ☑ Require a pull request before merging
  - ☑ Require approvals: 0
  - ☑ Dismiss stale pull request approvals when new commits are pushed
  - ☐ Require review from Code Owners (optional)
  - ☑ Restrict who can dismiss pull request reviews
  - ☑ Require approval of the most recent reviewable push

- ☑ Require status checks to pass before merging
  - ☑ Require branches to be up to date before merging
  - **Required status checks:** `test` (from test-pr.yaml workflow)

- ☑ Require conversation resolution before merging

- ☑ Require signed commits (optional, recommended)

- ☑ Require linear history

- ☑ Lock branch (prevent all pushes except from workflows and authorized merges)

- ☑ Restrict who can push to matching branches
  - Add: `github-actions[bot]` (allows workflows to push)
  - Add repository admins/owners who should be able to merge via `/merge` command

- ☐ Do not allow bypassing the above settings
  - Allow admins to bypass only for emergency fixes

## Alternative: Using Rulesets (Recommended for newer repositories)

GitHub Rulesets provide more flexible branch protection. Navigate to: **Settings → Rules → Rulesets**

### Create Ruleset for `master`

**Ruleset name:** `Protect master branch`

**Enforcement status:** Active

**Target branches:**
- Include by pattern: `master`

**Rules:**
- ☑ Restrict deletions
- ☑ Require a pull request before merging
  - Required approvals: 0
- ☑ Require status checks to pass
  - Status checks: `test`
- ☑ Block force pushes
- ☑ Require linear history
- ☑ Restrict who can push
  - Bypass list: Deploy keys and `github-actions`

### Create Ruleset for `dev`

**Ruleset name:** `Protect dev branch`

**Enforcement status:** Active

**Target branches:**
- Include by pattern: `dev`

**Rules:**
- ☑ Restrict deletions
- ☑ Require a pull request before merging
  - Required approvals: 0
- ☑ Require status checks to pass
  - Status checks: `test`
- ☑ Block force pushes
- ☑ Require linear history

## How This Enforces the Workflow

1. **Feature → Dev PRs:** Must pass tests, can only be merged via `/merge` command by owner/admin
2. **Dev → Master PRs:** Must pass tests, can ONLY be merged via `/release [major|minor|patch]` command
3. Manual merges via GitHub UI are disabled
4. Direct pushes to protected branches are blocked
5. Only GitHub Actions workflows can push to protected branches

## Testing the Protection

After configuring:
1. Try to merge a PR via GitHub UI → Should be blocked
2. Try to push directly to `master` or `dev` → Should be blocked
3. Comment `/merge` on a feature→dev PR as owner → Should merge successfully
4. Comment `/release patch` on a dev→master PR as owner → Should complete release process
