#!/bin/sh -l
set -e

# Configure git
echo "https://gitops:$GITHUB_TOKEN@github.com" > ~/.git-credentials
git config --local credential.helper store
git config --local user.email "${GIT_EMAIL}"
git config --local user.name "${GIT_NAME}"

BASE_BRANCH=$(git branch --show-current)
BRANCH="gitops-$(git rev-parse --short HEAD)"

# Check for an existing pull request
OPEN_PRS=$(gh pr list --base "$BASE_BRANCH" --head "$BRANCH" -q 'length' --json url)

if [ "${OPEN_PRS}" = "1" ]; then
  echo "Skipping PR creation because there's a pull request already exists."
  exit 0
fi

# Commit change
git add .
git commit -m "${COMMIT_PREFIX}: $COMMIT_MESSAGE"

# Create branch
git checkout -b $BRANCH
git push origin $BRANCH

# Create pull request
gh pr create --fill

# Merge pull request (optional)
if [ ! -z "$MERGE_AUTO" ]; then
    gh pr merge --$MERGE_TYPE
fi