This repo contains a collection of GitHub Actions:

# skaffold-build
Run `skaffold build` in your current repository.  Optionally, create ECR repositories.  Sample usage:

```
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
    - name: ECR Login
      id: ecr_login
      uses: aws-actions/amazon-ecr-login@v1
    - name: Skaffold Build
      uses: ./.github/actions/skaffold
      with:
        default_repo: ${{ steps.ecr_login.outputs.registry }}
```
