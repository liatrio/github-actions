#!/bin/sh -l
set -e

# Configure git
echo "https://gitops:$GITHUB_TOKEN@github.com" > ~/.git-credentials
git config --local credential.helper store
git config --local user.email "gitops@liatr.io"
git config --local user.name "GitOps Automation"

# Commit change
git add .
git commit -m "gitops: $COMMIT_MESSAGE"

# Create branch
BRANCH="gitops-$(git rev-parse --short HEAD)"
git checkout -b $BRANCH
git push origin $BRANCH

# Create pull request
gh pr create --fill

# Merge pull request (optional)
if [ ! -z "$MERGE_AUTO" ]; then
    gh pr merge --$MERGE_TYPE
fi