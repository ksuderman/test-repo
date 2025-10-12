# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This is a test repository for GitHub Actions and GitHub-related automation, specifically focused on Galaxy K8s deployments and ABM (Galaxy Benchmarking) workflows.

## Repository Structure

### Branching Strategy
- `master`: Latest stable release (merges only via GitHub workflows)
- `dev`: Latest development code (all PRs target this branch)
- `release_v.*`: Release-specific branches (e.g., `release_v2.10.2`)
- Feature branches: Use descriptive names with GitHub issue prefix (e.g., `1234-new-feature`)

### Versioning
- Semantic versioning is stored in the `VERSION` file at the repository root
- Current version: 1.4.0
- Use the `./bump` script to increment versions: `./bump [major|minor|patch]`

## Key Files

- `values.yml`: Helm values for Galaxy K8s deployment (includes Galaxy config, ingress, persistence, CVMFS, PostgreSQL, RabbitMQ)
- `VERSION`: Current semantic version number
- `bump`: Self-contained bash script to increment version numbers (no external dependencies)
- `RELEASE_DESIGN.md`: Documents the release process and automation design

### GitHub Workflows

- `.github/workflows/test.yaml`: Tests Galaxy K8s action with ABM benchmarks (can use workflow or repo-based config)
- `.github/workflows/repo.yaml`: Tests with repository-based configuration using aliases
- `.github/workflows/test-pr.yaml`: Runs on all PRs to `dev` or `master`, executes `test.sh` if present
- `.github/workflows/release.yaml`: Handles `/release [major|minor|patch]` command on dev→master PRs
- `.github/workflows/merge-guard.yaml`: Handles `/merge` command on feature→dev PRs
- `.github/workflows/master-docs-merge.yaml`: Handles `/merge` command for docs/config changes to master
- `.github/branch-protection.md`: Instructions for configuring branch protection in GitHub Settings

## Workflow Architecture

Both workflows follow a similar pattern:
1. Deploy Galaxy using `ksuderman/github-action-galaxy-k8s`
2. Install ABM (Galaxy Benchmarking tool) via pip
3. Configure ABM and create Galaxy users
4. Import workflows and histories
5. Run benchmarks

**Key difference**:
- `test.yaml`: Full manual configuration in workflow
- `repo.yaml`: Uses ABM aliases (e.g., `variant`, `variant-2g`) defined in `~/.abm/workflows.yml` and `~/.abm/histories.yml`

## Common ABM Commands

```bash
# Install ABM
pip install gxabm
abm --version

# Configuration
abm config create <profile> <kubeconfig>
abm config key <profile> <api-key>
abm config url <profile> <galaxy-url>
abm config list

# User management
abm <profile> user create <username> <email> <password>
abm <profile> user key <username>

# Import workflows and histories
abm <profile> workflow import <url-or-alias>
abm <profile> history import <url-or-alias>

# Benchmarking
abm <profile> benchmark validate <benchmark-file>
abm <profile> benchmark run <benchmark-file>

# Listing results
abm <profile> jobs list
abm <profile> history list
abm <profile> history summarize
```

## Merge and Release Process

### Merging Pull Requests

**All merges are controlled via chat-ops commands. Manual merges via GitHub UI must be disabled through branch protection.**

- **Feature → Dev PRs**: Comment `/merge` on the PR (owner only)
- **Dev → Master PRs**: Comment `/release [major|minor|patch]` on the PR (owner/admin only)
  - Do NOT use `/merge` on dev→master PRs, only `/release`
- **Docs/Config → Master PRs**: Comment `/merge` on the PR (owner only)
  - Only allowed for PRs that exclusively modify markdown files (*.md) or files in .github directory
  - Cannot be used for dev→master PRs (must use `/release` instead)

**Workflow behavior:**
- Valid commands receive a 🚀 reaction
- Invalid commands receive a 😕 reaction with error message
- Unauthorized users receive a 👎 reaction with denial message
- Successful operations post a ✅ confirmation comment

### Release Workflow (Dev → Master)

When an owner/admin comments `/release [major|minor|patch]` on a dev→master PR:
1. Validates the PR is from `dev` to `master`
2. Parses the bump type (major, minor, or patch)
3. Increments the VERSION file according to semantic versioning
4. Commits the version bump to `dev` branch
5. Merges `dev` into `master` (no-ff merge)
6. Creates a Git tag (e.g., `v1.4.1`)
7. Creates a GitHub release
8. Comments on PR with success status

### Merge Workflow (Feature → Dev)

When an owner comments `/merge` on a feature→dev PR:
1. Validates the user is a repository owner
2. Rejects if the PR is dev→master (must use `/release` instead)
3. Merges the PR using standard merge commit
4. Comments on PR with success status

### Master Docs/Config Merge Workflow

When an owner comments `/merge` on a PR to master (not from dev):
1. Validates the user is a repository owner
2. Rejects if the PR is from dev→master (must use `/release` instead)
3. Gets all changed files and validates they are either:
   - Markdown files (*.md)
   - Files in the .github directory
4. If validation passes, merges the PR using standard merge commit
5. If validation fails, comments with list of invalid files
6. Comments on PR with success status

### Branch Protection Setup Required

**⚠️ Important:** Branch protection must be configured manually in GitHub Settings to enforce the chat-ops workflow.

See `.github/branch-protection.md` for detailed configuration instructions.

**Key protections needed:**
- Lock both `master` and `dev` branches
- Disable manual merges via GitHub UI
- Require pull requests before merging
- Require `test` status check to pass
- Block direct pushes (except from `github-actions[bot]`)
- Restrict who can push to matching branches

## Data Directories

- `metrics/`: JSON files containing benchmark metrics
- `invocations/`: JSON files containing workflow invocations
