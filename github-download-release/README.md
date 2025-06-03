# GitHub Download Release

A GitHub Action that downloads release assets from GitHub repositories using curl. This action simplifies the process of fetching specific release artifacts from any GitHub repository as part of your workflow.

## Description

The `github-download-release` action allows you to download release assets from GitHub repositories by specifying the repository owner, repository name, release tag, and the desired asset format. It handles authentication and provides convenient outputs for further processing of the downloaded asset.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `token` | GitHub API token for authentication | Yes | - |
| `owner` | The repository owner | Yes | - |
| `repo` | The repository name | Yes | - |
| `release` | The release tag or number (use "latest" for the latest release) | Yes | - |
| `format-ext` | The file extension/format of the asset to download | No | `linux_amd64.tar.gz` |
| `file` | The explicit filename to use (overrides format-ext if provided) | No | - |

## Outputs

| Output | Description |
|--------|-------------|
| `filename` | The name of the downloaded file |
| `asset` | The GitHub API URL of the asset |
| `web` | The web URL for the downloaded asset |

## Usage

### Basic Example

```yaml
jobs:
  download-release:
    runs-on: ubuntu-latest
    steps:
      - name: Download Release Asset
        id: download
        uses: liatrio/github-actions/github-download-release@main
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          owner: octocat
          repo: hello-world
          release: v1.0.0
          format-ext: linux_amd64.tar.gz
      
      - name: Use Downloaded Asset
        run: |
          echo "Downloaded file: ${{ steps.download.outputs.filename }}"
          tar -xzf ${{ steps.download.outputs.filename }}
          # Use the extracted files
```

### Download Latest Release

```yaml
- name: Download Latest Release
  uses: liatrio/github-actions/github-download-release@main
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    owner: octocat
    repo: hello-world
    release: latest
    format-ext: linux_amd64.tar.gz
```

### Download Specific File

```yaml
- name: Download Specific File
  uses: liatrio/github-actions/github-download-release@main
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    owner: octocat
    repo: hello-world
    release: v1.0.0
    file: specific-filename.zip
```

## How It Works

1. The action authenticates with the GitHub API using the provided token
2. It queries the GitHub API to find the specified release and asset
3. For the "latest" release, it selects the first release returned by the API
4. It downloads the asset using curl with the appropriate authentication headers
5. The downloaded file is saved to the workspace with the specified filename
6. The action outputs the filename, asset URL, and web URL for further use

## Notes

- If no specific `file` is provided, the action constructs a filename using the pattern: `{repo}_{release-tag}_{format-ext}`
- The action will fail if the specified release or asset cannot be found
- The `token` input should have appropriate permissions to access the repository and its releases
- When using `release: latest`, ensure that the repository has published releases (not just tags)
