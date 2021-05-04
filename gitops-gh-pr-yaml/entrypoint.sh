#!/bin/sh -l
set -e

# Configure git
echo "https://gitops:$GITHUB_TOKEN@github.com" > ~/.git-credentials
git config --local credential.helper store
git config --local user.email "gitops@liatr.io"
git config --local user.name "GitOps Automation"

# Clone repo
# gh repo clone $GITHUB_REPO repo
# cd charts

# Change manifest value
yq w -i $MANIFEST_FILE $MANIFEST_PATH $MANIFEST_VALUE

# Commit change
MESSAGE="gitops: update $MANIFEST_FILE $MANIFEST_PATH to $MANIFEST_VALUE"
git commit $MANIFEST_FILE -m "$MESSAGE"

# Create branch
BRANCH="gitops-$(git rev-parse --short HEAD)"
git checkout -b $BRANCH
git push origin $BRANCH

# Create pull request
gh pr create --fill

# Merge pull request (optional)
if [ ! -z "$MERGE_PR" ]; then
    gh pr merge --rebase
fi