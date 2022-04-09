# Apprenticeship Interview Exercise

This [GitHub Action](https://github.com/features/actions) is used to verify the functionality of the application created as part of Liatrio's apprenticeship interview exercise and should be included as a step in the GitHub Workflow created for the exercise. It will execute some endpoint tests (HTTP calls) against your application and ensure that your application has the expected behavior.

This action defaults to testing port 80.

### How to use
1. Include the action in your GitHub Workflow
2. Run the workflow and verify that the tests pass

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: run tests
      uses: liatrio/github-actions/apprentice-action@master
```

