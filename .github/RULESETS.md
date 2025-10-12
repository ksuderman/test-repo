# GitHub Rulesets Configuration

This directory contains JSON configuration files for GitHub repository rulesets that enforce the branch protection requirements for the release workflow.

## Files

- `ruleset-master.json`: Ruleset configuration for the `master` branch
- `ruleset-dev.json`: Ruleset configuration for the `dev` branch
- `apply-rulesets.sh`: Shell script to apply both rulesets automatically

## Quick Start

Apply both rulesets with a single command:

```bash
./.github/apply-rulesets.sh
```

## Manual Application

You can also apply rulesets individually using the `gh` CLI:

### Apply Master Branch Ruleset

```bash
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/{owner}/{repo}/rulesets" \
  --input .github/ruleset-master.json
```

### Apply Dev Branch Ruleset

```bash
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/{owner}/{repo}/rulesets" \
  --input .github/ruleset-dev.json
```

Replace `{owner}/{repo}` with your repository path (e.g., `ksuderman/test-repo`).

## What These Rulesets Enforce

### Master Branch Protection

- **Deletion protection**: Branch cannot be deleted
- **Force push blocking**: No force pushes allowed
- **Linear history**: Requires clean, linear git history
- **Pull request requirement**: All changes must go through PRs
  - No approval reviews required (workflow handles merging)
  - Stale reviews dismissed on new pushes
  - Most recent push must be approved
  - Conversation threads must be resolved
- **Status check requirement**: `test` workflow must pass
  - Branch must be up to date before merging
- **Bypass actors**: Only repository admins can bypass (for emergencies)

### Dev Branch Protection

- **Deletion protection**: Branch cannot be deleted
- **Force push blocking**: No force pushes allowed
- **Linear history**: Requires clean, linear git history
- **Pull request requirement**: All changes must go through PRs
  - No approval reviews required (workflow handles merging)
  - Stale reviews dismissed on new pushes
  - Most recent push must be approved
  - Conversation threads must be resolved
- **Status check requirement**: `test` workflow must pass
  - Branch must be up to date before merging
- **Bypass actors**: Repository admins can bypass (for emergencies)

## Managing Rulesets

### List All Rulesets

```bash
gh api /repos/{owner}/{repo}/rulesets
```

### View Specific Ruleset

```bash
gh api /repos/{owner}/{repo}/rulesets/{ruleset_id}
```

### Update a Ruleset

```bash
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/{owner}/{repo}/rulesets/{ruleset_id}" \
  --input .github/ruleset-master.json
```

### Delete a Ruleset

```bash
gh api \
  --method DELETE \
  "/repos/{owner}/{repo}/rulesets/{ruleset_id}"
```

## Bypass Actor Configuration

The rulesets currently include a bypass actor with ID 5, which corresponds to the "Repository Admin" role. This allows:

- Emergency fixes to be pushed directly by admins if needed
- The `github-actions[bot]` account to push changes from workflows

To restrict this further, you can:
1. Remove the bypass_actors section entirely (no bypasses allowed)
2. Change the actor_id to restrict to specific users or teams

### Common Actor Types

- `RepositoryRole`: Role-based access (actor_id 5 = Admin, 4 = Maintain, 2 = Write, 1 = Read)
- `Integration`: GitHub Apps (use the app's integration ID)
- `OrganizationAdmin`: All organization administrators
- `Team`: Specific team (use team ID)

## Troubleshooting

### Error: Resource not accessible by integration

Make sure you're authenticated with the `gh` CLI:

```bash
gh auth login
```

### Error: Rulesets already exist

If rulesets with the same name already exist, either:
1. Delete the existing rulesets first
2. Modify the "name" field in the JSON files
3. Use PUT instead of POST to update existing rulesets

## Testing the Protection

After applying the rulesets:

1. Try to push directly to `master` or `dev` → Should be blocked
2. Try to merge a PR without required status checks passing → Should be blocked
3. Try to force push to protected branches → Should be blocked
4. Comment `/merge` on a feature→dev PR → Should work (via workflow)
5. Comment `/release patch` on a dev→master PR → Should work (via workflow)
