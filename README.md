This repo contains a collection of GitHub Actions:

# skaffold-build
Run `skaffold build` in your current repository.  Options:

* **login_ecr** set to `true` if you'd like to login to ECR (Default: true)
* **create_ecr** set to `true` if you'd like to create ECR repositories from skaffold.yaml (Default: true)

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
    - name: Skaffold Build
      uses: ./.github/actions/skaffold
```
