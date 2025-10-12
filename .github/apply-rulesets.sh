#!/bin/bash
# Script to apply GitHub rulesets using the gh CLI

set -e

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Get repository information
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "Applying rulesets to repository: $REPO"

# Apply master branch ruleset
echo ""
echo "Creating ruleset for master branch..."
/usr/local/bin/gh api \
  "/repos/$REPO/rulesets" \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  --input .github/ruleset-master.json

echo "✓ Master branch ruleset created"

# Apply dev branch ruleset
echo ""
echo "Creating ruleset for dev branch..."
/usr/local/bin/gh api \
  "/repos/$REPO/rulesets" \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  --input .github/ruleset-dev.json

echo "✓ Dev branch ruleset created"

echo ""
echo "All rulesets have been successfully applied!"
echo ""
echo "To view rulesets:"
echo "  gh api /repos/$REPO/rulesets"
echo ""
echo "To delete a ruleset (if needed):"
echo "  gh api --method DELETE /repos/$REPO/rulesets/{ruleset_id}"
