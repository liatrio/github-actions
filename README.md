This repo contains a collection of GitHub Actions:

# ecr
Login and setup ECR.  Supports following inputs

* **login** set to `true` if you'd like to login to ECR (Default: true)
* **create_repos** set to `true` if you'd like to create ECR repositories from skaffold.yaml (Default: true)

Provides following outputs:

* **registry** the ECR registry

```
# Sample workflow

jobs:
  build:
    runs-on: ubuntu-18.04
    steps:
    - uses: actions/checkout@v2
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}
        role-duration-seconds: 1200
    - uses: ./.github/actions/ecr
```

# skaffold-build
Run `skaffold build` in your current repository.  Options:

* **default_repo** Repo to push to.  Set to '' to skip pushing (Default: '')
* **docker_username** Username to use when running `docker login`. Omit to skip `docker login`
* **docker_password** Password to use when running `docker login`. Omit to skip `docker login`
* **docker_registry** Registry to use when running `docker login`. Omit to skip `docker login`

```
    - name: Skaffold Build
      uses: ./.github/actions/skaffold
```

# gitty-up
Run `gitty-up` in your current repository.  Options:

* **url** the Git URL to push to
* **username** the Git Username to use 
* **password** the Git Password to use
* **file** the file to update
* **values** the values to set in `file`

```
# Sample workflow

jobs:
  build:
    runs-on: ubuntu-18.04
    steps:
    - uses: actions/checkout@v2
    - name: GitOps
      uses: liatrio/github-actions/gitops@master
      with:
        url: https://github.com/liatrio/lead-environments.git
        username: ${{ github.actor }}
        password: ${{ secrets.GITTY_UP_TOKEN }}
        file: aws/liatrio-sandbox/terragrunt.hcl
        values: inputs.sdm_version=1.3.16
```

# git-extra
Get extra information about current git repo.  Creates following outputs:

* **version** determined by `git describe`

```
# Sample workflow

jobs:
  build:
    runs-on: ubuntu-18.04
    steps:
    - uses: actions/checkout@v2
    - id: git
      uses: liatrio/github-actions/git-extra@master
    - uses: liatrio/github-actions/gitops@master
      with:
        values: inputs.sdm_version=${{ steps.git.outputs.version}}
```

# helm-push
Package and push a helm chart.  Supports following inputs:

* **bucket** Bucket to to push to
* **chart** Path to helm chart
* **version** Version to update
* **appVersion** App version to update
* **dependencies** App version to update

```
# Sample 

jobs:
  build:
    runs-on: ubuntu-18.04
    steps:
    - name: Helm Chart
      uses: liatrio/github-actions/helm-push@master
      with:
        chart: charts/operator-toolchain
        bucket: liatrio-helm
        version: v1.0.0
        appVersion: v1.0.0
        dependencies: '[{"name":"elastic","url":"https://helm.elastic.co"}]'

```

# GitOps

These actions can be used together in a job to make changes to a source repo and create a pull request to trigger a update in a downstream dependency.

 - [gitops-gh-pr](./gitops-gh-pr/)
 - [gitops-update-yaml](./gitops-update-yaml/)
 - [gitops-semver-increment-yaml](./gitops-semver-increment-yaml/)

# oauth2-token

An action for fetching an access token using the client credentials flow. 
The `accessToken` output is [masked](https://docs.github.com/en/actions/reference/workflow-commands-for-github-actions#masking-a-value-in-log) from the build logs.

```yaml
jobs:
  demo:
    steps:
    - name: Fetch Token
      uses: liatrio/github-actions/oauth2-token@master
      id: token
      with:
        clientId: ${{ secrets.CLIENT_ID }}
        clientSecret: ${{ secrets.CLIENT_SECRET }}
        scopes: "custom_scope" # optional
        tokenUrl: https://idp.example.com/oauth2/token
    - name: API Request
      run: |
        curl -H "Authorization: Bearer ${{ steps.token.outputs.accessToken }}" https://api.example.com/protected
```

# conventional-release

The actions wraps [semantic-release](https://github.com/semantic-release/semantic-release), which can be used to automatically 
bump the version (based on [conventional commits](https://www.conventionalcommits.org/)), generate changelogs, and create GitHub releases.

The repository should include a `semantic-release` [config file](https://github.com/semantic-release/semantic-release/blob/master/docs/usage/configuration.md#configuration)
as there's likely a need to change the defaults for non-JavaScript projects. 

```yaml
jobs:
  release:
    steps:
      - name: Checkout Code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Release
        uses: liatrio/github-actions/conventional-release@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

# conventional-pr-title

A GitHub Action for enforcing that pull request titles use [conventional commit prefixes](https://www.conventionalcommits.org/en/v1.0.0/).
By default, the action uses the conventional commit preset list (minus `chore:`), but that can be overwritten by passing the `prefixes` input.

For pull requests with a single commit, the action will check that the commit uses an allowed prefix. This is because GitHub
uses the commit message instead of the pull request title as the default text in the squash merge dialog when the branch only has a single commit.
Note that this action should be used with repositories that only permit squash merge; this will help enforce that only conventional commit prefixes land in the target branch. 

```yaml
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: liatrio/github-actions/conventional-pr-title@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```

# apprentice-action 

This action will execute some endpoint tests (HTTP calls) against your application.
It will ensure that your application has the expected behaviour.

### How to use
1. Import the action to your Workflow
2. Launch your workflow and verify that the tests pass
