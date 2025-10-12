# Release Process Design

A system is needed to coordinate and automate the release process in a way that will work in any GitHub repository.

The process should utilize GitHub actions and workflows to perform tasks based on events such as merges into the `master` or `dev` branches, or when a repository owner comments on a PR with a GitHub chat-ops command.

## Repository Layout

1. the `master` branch contains the latest stable release.  Nothing will merge code into the `master` branch except for GitHub workflows triggered by repository owners.
2. the `dev` branch contains the latest development code. All pull requests should target the `dev` branch.
3. `release_v.*` branches contain the code for a given release, eg `release_v2.10.2`
4. features branch names should be descriptive and preferably reference a GitHub issue as a prefix for the branch name, eg 1234-new-feature refers to the GitHub issue #1234

## Versioning

All artifacts will use semantic versioning. When a release is performed one of `major`, `minor`, or `patch` will be specified indicating which part of the version number should be incremented.

The current version number will always be stored in a file named `VERSION` at the root of the repository.

## Release Process

A pull request from a feature branch to the `dev` branch should trigger a simple test GitHub workflow.  Since this project is intended to be used as a template for other projects this test workflow should simply check for the presence of a file named `test.sh` and if found run it.

A pull request from `dev` into `master` should trigger the same simple test GitHub workflow from above.  If a repository owner or admin comments on the pull request with `/release [major|minor|patch]` then the following actions are to take place:

1. The version in the VERSION file should be incremented according to the major, minor, or patch argument supplied with the `/release` comment.
2. The `dev` branch should be merged into the `master` branch.
3. A new GitHub tag should be created using the version number as the tag name,
4. A GitHub release should be done using the tag created above,


