# Test

A repository used to test GitHub actions and other things GitHub related.

## Branching Strategy

- `master`: Latest stable release (only updated via automated release process)
- `dev`: Development branch (all feature PRs target this branch)
- Feature branches: Create from `dev` with descriptive names

## Pull Request and Merge Process

This repository uses **chat-ops commands** to manage merges. Manual merges via GitHub UI are disabled through branch protection rulesets.

### Feature → Dev Pull Requests

1. Create a PR from your feature branch to `dev`
2. The `test` workflow will run automatically
3. Once tests pass and you're ready to merge, comment on the PR:
   ```
   /merge
   ```
4. Only **repository owners** can use the `/merge` command
5. The workflow will:
   - Add a 🚀 reaction to confirm the command
   - Merge the PR using a merge commit
   - Post a ✅ confirmation comment

**Note:** Unauthorized users will receive a 👎 reaction and an error message.

### Dev → Master Pull Requests (Release Process)

1. Create a PR from `dev` to `master`
2. Once ready to release, comment on the PR with the version bump type:
   ```
   /release [major|minor|patch]
   ```
   Examples:
   - `/release major` - for breaking changes (1.0.0 → 2.0.0)
   - `/release minor` - for new features (1.0.0 → 1.1.0)
   - `/release patch` - for bug fixes (1.0.0 → 1.0.1)

3. Only **repository owners or admins** can use the `/release` command
4. The workflow will:
   - Add a 🚀 reaction to confirm the command
   - Bump the VERSION file according to semantic versioning
   - Commit the version bump to `dev`
   - Merge `dev` into `master` (no-ff merge)
   - Create a Git tag (e.g., `v1.4.1`)
   - Create a GitHub release
   - Post a ✅ confirmation comment with release details

**Important:** Do NOT use `/merge` on dev → master PRs. Only `/release` is allowed.

### Documentation/Config → Master Pull Requests

For quick updates to documentation or GitHub configuration files, you can merge directly to master:

1. Create a PR from a feature branch to `master`
2. Ensure the PR **only** contains changes to:
   - Markdown files (`*.md`)
   - Files in the `.github/` directory
3. Once ready, comment on the PR:
   ```
   /merge
   ```
4. Only **repository owners** can use the `/merge` command
5. The workflow will:
   - Add a 🚀 reaction to confirm the command
   - Validate all changed files are markdown or GitHub config files
   - Merge the PR to `master` if validation passes
   - Automatically merge the changes from `master` back into `dev` to keep branches in sync
   - Post ✅ confirmation comments for both operations

**Note:**
- If the PR contains any other file types, it will be rejected with a 😕 reaction and a list of invalid files
- This bypass is only for documentation and configuration changes that don't affect the version
- Cannot be used for `dev` → `master` PRs (must use `/release` instead)
- The automatic sync to `dev` ensures documentation/config changes don't cause branch divergence

## Branch Protection

Both `dev` and `master` branches are protected with the following rulesets:

- **Deletion protection**: Branches cannot be deleted
- **No force pushes**: Force push is disabled
- **Required linear history**: No merge commits from external sources
- **Pull request required**: All changes must go through PRs
- **Required status check**: The `test` workflow must pass before merging
- **Last push approval**: The last push must be approved

The GitHub Actions bot has bypass permissions to enable automated merges.

## Automated Workflows

### Test Workflow
- **Trigger**: All PRs to `dev` or `master`
- **Purpose**: Runs `test.sh` if present in the repository
- **Status**: Required to pass before merging

### Merge Guard Workflow
- **Trigger**: `/merge` comment on PRs
- **Purpose**: Automates merging feature → dev PRs
- **Permissions**: Repository owners only

### Release Workflow
- **Trigger**: `/release [major|minor|patch]` comment on PRs
- **Purpose**: Automates version bumping and releases for dev → master PRs
- **Permissions**: Repository owners and admins only

### Master Docs/Config Merge Workflow
- **Trigger**: `/merge` comment on PRs to master (not from dev)
- **Purpose**: Allows quick merging of documentation and configuration changes to master, then syncs to dev
- **Restrictions**: Only markdown files (`*.md`) and `.github/` directory files allowed
- **Permissions**: Repository owners only
- **Additional behavior**: Automatically merges changes back to `dev` branch after merging to `master`
