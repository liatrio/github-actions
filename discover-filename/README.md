# Discover Filename Targets

A GitHub Action that identifies directories containing a specific filename within target directories. This action is useful for implementing efficient CI/CD pipelines that only process directories containing specific configuration or marker files.

## Description

The `discover-filename` action searches through specified target directories for a given filename. It then outputs a JSON array containing the paths of directories that contain the specified file, which can be used in a matrix strategy for subsequent workflow steps.

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `targets` | A newline-delimited string of target folders to check | Yes |
| `filename` | The specific filename to search for | Yes |

## Outputs

| Output | Description |
|--------|-------------|
| `matrix` | A JSON-formatted array of directory paths containing the specified filename |

## Usage

### Basic Example

```yaml
jobs:
  discover-directories:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.discover.outputs.matrix }}
    steps:
      - uses: actions/checkout@v3
      
      - name: Discover Directories with package.json
        id: discover
        uses: liatrio/github-actions/discover-filename@main
        with:
          targets: |
            services
            packages
          filename: package.json

  build:
    needs: discover-directories
    if: ${{ needs.discover-directories.outputs.matrix != '[]' }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        directory: ${{ fromJson(needs.discover-directories.outputs.matrix) }}
    steps:
      - name: Build ${{ matrix.directory }}
        run: |
          cd ${{ matrix.directory }}
          npm install
          npm run build
```

## How It Works

1. The action iterates through each specified target directory
2. For each target, it uses the `find` command to locate all instances of the specified filename
3. It extracts the directory path for each matching file
4. It creates a unique, sorted list of these directory paths
5. It outputs this list as a JSON array that can be used in a matrix strategy

## Use Cases

- Finding all Node.js projects by searching for `package.json` files
- Locating all services with a specific configuration file (e.g., `config.yaml`)
- Identifying directories containing specific marker files (e.g., `Dockerfile`, `Jenkinsfile`)
- Running tests only in directories that contain test files (e.g., `test.js`)

## Notes

- The action uses `find -mindepth 1` to exclude the target directory itself from the results
- Directory paths in the output are relative to their respective target directory
- The action changes directory to the parent of each target before searching, so paths in the output are relative to that parent