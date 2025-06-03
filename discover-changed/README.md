# Discover Changed Targets

A GitHub Action that identifies which target directories have been modified in a repository. This action is useful for implementing efficient CI/CD pipelines that only process directories that have actually changed.

## Description

The `discover-changed` action scans your repository for modified files within specified target directories. It then outputs a JSON array containing the names of directories that have changes, which can be used in a matrix strategy for subsequent workflow steps.

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `targets` | A newline-delimited string of target folders to check | Yes |

## Outputs

| Output | Description |
|--------|-------------|
| `matrix` | A JSON-formatted array of changed target directories |

## Usage

### Basic Example

```yaml
jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.discover.outputs.matrix }}
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: Discover Changed Targets
        id: discover
        uses: liatrio/github-actions/discover-changed@main
        with:
          targets: |
            service1
            service2
            service3

  build:
    needs: detect-changes
    if: ${{ needs.detect-changes.outputs.matrix != '[]' }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        target: ${{ fromJson(needs.detect-changes.outputs.matrix) }}
    steps:
      - name: Build ${{ matrix.target }}
        run: echo "Building ${{ matrix.target }}"
```

## How It Works

1. The action uses `tj-actions/changed-files@v34` to identify modified files within the specified target directories
2. It extracts the directory names from the file paths (assuming a structure like `target/subdirectory/file.ext`)
3. It creates a unique, sorted list of these directory names
4. It outputs this list as a JSON array that can be used in a matrix strategy

## Notes

- This action assumes a specific repository structure where the target directories are at the root level
- The action extracts the second segment of each file path using `cut -d'/' -f2`, so it's designed for repositories with a structure like `target/subdirectory/file.ext`

## ⚠️ Important Limitation

This action has a significant limitation to be aware of: if multiple target directories contain identically-named subdirectories (e.g., multiple services with a `src` directory), and changes are made in those subdirectories across different targets, the action will only report a single instance of that subdirectory name in the matrix output.

For example, if you have changes in both `service1/src/file1.txt` and `service2/src/file2.txt`, the output matrix will be `["src"]`, not `["service1/src", "service2/src"]` or `["service1", "service2"]`.

This means:
- You cannot determine which specific target directories had changes
- If you're using this for a matrix build strategy, you'll only run one job for all changes in identically-named subdirectories

Consider this limitation when deciding if this action is appropriate for your workflow.