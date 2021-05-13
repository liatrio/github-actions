# GitOps GitHub Pull Request YAML Update Action

Commits all current changes and creates a GitHub Pull Request. Used as the last step in a job to apply changes to a GitOps or downstream repo to trigger a release.

**Additional GitOps Actions:**
 - [gitops-update-yaml](../gitops-update-yaml/)
 - [gitops-semver-increment-yaml](../gitops-semver-increment-yaml/)


## Inputs
- **repo:** GitHub repo to update [ORG_OR_USERNAME/REPO]
- **token:** GitHub personal access token (PAT). 
- **auto-merge:** Automatically merge pull request ([]) 

## Example

```yaml
name: publish

on: 
  push:
    tags:
      - v*.*.*

jobs:
  build-version:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
      # Additional steps to build and publish new version

  promote-version:
    needs: build-version
    runs-on: ubuntu-latest
    steps:
      # Check out target repository source to update
      - name: Checkout
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
          persist-credentials: false
          repository: ORG/TARGET_REPO
      # Get current version from git tag
      - name: Get tag
        id: tag
        run: echo ::set-output name=TAG::${GITHUB_REF#refs/tags/v}
      # Update version values in target repository source
      - name: Increment release version
        uses: liatrio/github-actions/gitops-semver-increment-yaml@master
        with:
          file: chart/Chart.yaml
          path: version
          position: PATCH
      - name: Update application version
        uses: liatrio/github-actions/gitops-update-yaml@master
        with:
          file: chart/Chart.yaml
          path: appVersion
          value: ${{ steps.tag.outputs.TAG }}
      - name: Create pull request
        uses: liatrio/github-actions/gitops-gh-pr@master
        with:
          repo: ORG/TARGET_REPO # Target repository to update
          token: ${{ secrets.GITOPS_TOKEN }}
          message: "update application version to ${{ steps.tag.outputs.TAG }}"
```
