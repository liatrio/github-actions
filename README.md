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
