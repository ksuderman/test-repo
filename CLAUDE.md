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
- `bump`: Bash script to increment version numbers
- `RELEASE_DESIGN.md`: Documents the release process and automation design
- `.github/workflows/test.yaml`: Tests Galaxy K8s action with ABM benchmarks (can use workflow or repo-based config)
- `.github/workflows/repo.yaml`: Tests with repository-based configuration using aliases

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

## Release Process

Pull requests from `dev` to `master` trigger releases when a repository owner comments `/release [major|minor|patch]`, which:
1. Increments the VERSION file
2. Merges `dev` into `master`
3. Creates a GitHub tag with the version number
4. Creates a GitHub release

## Data Directories

- `metrics/`: JSON files containing benchmark metrics
- `invocations/`: JSON files containing workflow invocations
