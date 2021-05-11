# GitOps Update Value YAML

Update a value in a YAML file. This action is meant to be used in a job which updates values in another source repository to trigger a downstream update. See [gitops-gh-pr](../gitops-gh-pr/) for a complete example.

## Inputs
- **file:** File to update version in
- **path:** Expression path of version in YAML
- **value:** New value to update in YAML
