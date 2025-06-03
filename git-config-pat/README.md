# Git Config With PAT

A GitHub Action that configures Git to use a Personal Access Token (PAT) for authentication when accessing GitHub repositories. This action is particularly useful for workflows that need to interact with private repositories or perform Git operations that require authentication.

## Description

The `git-config-pat` action modifies the global Git configuration to replace SSH URLs with HTTPS URLs that include authentication credentials. This allows Git operations to authenticate with GitHub using the provided token instead of SSH keys, which can be more convenient in CI/CD environments.

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `token` | GitHub API token (Personal Access Token) | Yes |

## Outputs

| Output | Description |
|--------|-------------|
| `gitconfig` | The path to the `.gitconfig` file that was modified |

## Usage

### Basic Example

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure Git with PAT
        uses: liatrio/github-actions/git-config-pat@main
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Clone Private Repository
        run: |
          git clone https://github.com/org/private-repo.git
          cd private-repo
          # Perform operations on the private repository
```

## How It Works

The action performs the following steps:

1. Takes the provided GitHub token and sets it as an environment variable
2. Configures Git globally to replace SSH URLs with HTTPS URLs that include authentication credentials
3. Specifically, it runs:
   ```bash
   git config --global url."https://${GITHUB_ACTOR}:${GH_PAT}@github.com".insteadOf ssh://git@github.com
   ```
4. Outputs the path to the modified `.gitconfig` file

## Use Cases

- Cloning private repositories in CI/CD workflows
- Pushing changes to repositories that require authentication
- Working with multiple repositories in a single workflow
- Automating Git operations that require authentication

## Security Considerations

- The action uses the GitHub token securely by passing it as an environment variable
- The token is not exposed in command-line arguments or logs
- However, be aware that the token is stored in the `.gitconfig` file, which could potentially be accessed by other steps in your workflow

## Notes

- This action only affects Git operations within the GitHub Actions runner environment
- The configuration is set globally for the current user, so it applies to all Git operations in the workflow
- The action specifically replaces SSH URLs with HTTPS URLs, so it won't affect operations that already use HTTPS URLs without the need for authentication