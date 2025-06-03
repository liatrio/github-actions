# Verify Checksum

A GitHub Action that provides utility functions for verifying file checksums in CI/CD workflows. This action helps ensure the integrity and authenticity of downloaded files by comparing their checksums against expected values.

## Description

The `verify-checksum` action creates and installs a verification script that can be used to validate file checksums. It's particularly useful when combined with other actions that download external resources, such as the `terragrunt-wrapper` action, to ensure that downloaded binaries haven't been tampered with.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|--------|
| `script-path` | Path where the verification script will be installed | No | `${{ github.workspace }}/verify.sh` |

## Outputs

| Output | Description |
|--------|-------------|
| `script-path` | The path to the installed verification script |

## Usage

### Basic Example

```yaml
jobs:
  verify-downloads:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Verification Script
        id: verify
        uses: liatrio/github-actions/verify-checksum@main
      
      - name: Download File
        run: |
          curl -L -o myfile.zip https://example.com/myfile.zip
      
      - name: Verify Downloaded File
        run: |
          ${{ steps.verify.outputs.script-path }} myfile.zip SHA256SUMS sha256sum
```

### Using with Terragrunt Wrapper

```yaml
- name: Install Verification Script
  id: verify
  uses: liatrio/github-actions/verify-checksum@main

- name: Setup Terragrunt
  uses: liatrio/github-actions/terragrunt-wrapper@main
  with:
    terragrunt-wrapper-command: install
    terraform-version: v1.3.6
    terragrunt-version: v0.31.1
  env:
    VERIFY_TOOL: ${{ steps.verify.outputs.script-path }}
```

## How It Works

1. The action installs a verification script at the specified path
2. The script can be called with the following parameters:
   - `FILENAME`: The file to verify
   - `CHECKSUM`: Either a checksum value or a file containing checksums
   - `COMMAND`: The checksum command to use (currently supports `sha256sum`)
3. The script verifies that the file's checksum matches the expected value

## Script Usage

```bash
# Verify using a checksum file
./verify.sh downloaded-file.zip SHA256SUMS sha256sum

# Verify using a direct checksum value
./verify.sh downloaded-file.zip "a1b2c3d4e5f6..." sha256sum
```

## Security Considerations

- Always use trusted sources for checksum files
- Consider using cryptographic signatures in addition to checksums for critical files
- The action currently supports SHA-256 checksums, which are considered secure for file verification

## Notes

- The verification script returns a non-zero exit code if verification fails
- Colorized output is provided for easy visual confirmation
- The script can handle both direct checksum values and checksum files