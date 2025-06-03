# Terragrunt Wrapper

A GitHub Action that simplifies the setup and execution of Terragrunt commands in your CI/CD workflows. This action handles the installation of Terraform and Terragrunt with specific versions and provides a consistent interface for common operations.

## Description

The `terragrunt-wrapper` action automates the installation and configuration of Terraform and Terragrunt tools, then provides a simple interface to run common commands like `init`, `plan`, `apply`, and `fmt`. It handles the complexity of working with Terragrunt in CI/CD environments, including proper initialization, plan file generation, and output management.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|--------|
| `terraform-version` | The version of Terraform to install | No | `v1.3.6` |
| `terragrunt-version` | The version of Terragrunt to install | No | `v0.31.1` |
| `terragrunt-wrapper-command` | The Terragrunt command to execute (`install`, `init`, `plan`, `apply`, `fmt`) | Yes | - |
| `terragrunt-working-dir` | The directory containing Terragrunt configuration | No | Current directory |
| `arch` | The system architecture for downloaded binaries | No | `linux_amd64` |

## Outputs

| Output | Description |
|--------|-------------|
| `terraform-path` | The path to the installed Terraform binary |
| `terragrunt-path` | The path to the installed Terragrunt binary |
| `planfile` | The path to the generated Terraform plan file (when using the `plan` command) |

## Usage

### Installation

```yaml
jobs:
  terraform-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terragrunt
        uses: liatrio/github-actions/terragrunt-wrapper@main
        id: terragrunt-setup
        with:
          terragrunt-wrapper-command: install
          terraform-version: v1.3.6
          terragrunt-version: v0.31.1
```

### Planning Infrastructure Changes

```yaml
- name: Terragrunt Plan
  uses: liatrio/github-actions/terragrunt-wrapper@main
  with:
    terragrunt-wrapper-command: plan
    terragrunt-working-dir: ./infrastructure/dev
```

### Applying Infrastructure Changes

```yaml
- name: Terragrunt Apply
  uses: liatrio/github-actions/terragrunt-wrapper@main
  with:
    terragrunt-wrapper-command: apply
    terragrunt-working-dir: ./infrastructure/dev
```

### Formatting Terraform Code

```yaml
- name: Terragrunt Format
  uses: liatrio/github-actions/terragrunt-wrapper@main
  with:
    terragrunt-wrapper-command: fmt
    terragrunt-working-dir: ./infrastructure
```

## How It Works

1. **Installation Mode**: When run with the `install` command, the action:
   - Downloads and installs the specified versions of Terraform and Terragrunt
   - Verifies checksums of downloaded binaries for security
   - Adds the tools to the PATH for subsequent steps

2. **Command Mode**: When run with other commands (`init`, `plan`, `apply`, `fmt`), the action:
   - Automatically initializes Terragrunt in the specified working directory
   - Executes the requested command with appropriate flags
   - For `plan` command, generates a uniquely named plan file and outputs its path

## Requirements

- GitHub Actions runner with bash shell support
- Internet access to download Terraform and Terragrunt binaries
- Appropriate AWS credentials or other provider authentication if required by your Terraform code

## Notes

- The action uses a unique UUID for plan file names to avoid conflicts in parallel workflows
- When using the `plan` command, both the binary plan file and a JSON representation are created
- The action sets GitHub environment variables and outputs for easy reference in subsequent steps
- Checksum verification is performed on downloaded binaries for security