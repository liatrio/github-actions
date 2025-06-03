# Terraform Compliance with Terragrunt

A GitHub Action that runs terraform-compliance checks against Terragrunt-managed infrastructure code. This action helps ensure your infrastructure-as-code follows best practices, security policies, and compliance requirements.

## Description

The `terraform-compliance-terragrunt` action combines the power of [terraform-compliance](https://terraform-compliance.com/) (a BDD-style test framework) with [Terragrunt](https://terragrunt.gruntwork.io/) (a thin wrapper for Terraform) to validate your infrastructure code against compliance policies. It automatically generates Terraform plans for your Terragrunt modules and runs compliance checks against them.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|--------|
| `target-folder` | The root folder containing Terragrunt configurations | Yes | - |
| `subfolders` | Space-delimited list of subfolders containing terragrunt.hcl files | No | `""` (empty string) |
| `planfile` | Name of the Terraform plan file to generate | Yes | - |
| `features` | Path to features directory or git repository URL with compliance tests | No | `git:https://github.com/terraform-compliance/user-friendly-features.git` |
| `options` | Additional options to pass to terraform-compliance | No | `-n` |

## Usage

### Basic Example

```yaml
jobs:
  compliance-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.0.0
      
      - name: Setup Terragrunt
        run: |
          wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.38.0/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt
          chmod +x /usr/local/bin/terragrunt
      
      - name: Run Terraform Compliance
        uses: liatrio/github-actions/terraform-compliance-terragrunt@main
        with:
          target-folder: "./terraform"
          subfolders: "dev prod"
          planfile: "tfplan"
```

### Custom Compliance Rules

```yaml
- name: Run Terraform Compliance with Custom Rules
  uses: liatrio/github-actions/terraform-compliance-terragrunt@main
  with:
    target-folder: "./terraform"
    subfolders: "dev prod"
    planfile: "tfplan"
    features: "git:https://github.com/myorg/custom-compliance-rules.git"
    options: |
      -n
      --no-failure
```

## How It Works

1. The action installs terraform-compliance using pip
2. For each specified subfolder, it:
   - Changes to the subfolder directory
   - Generates a Terraform plan using Terragrunt
   - Converts the plan to JSON format
   - Runs terraform-compliance against the JSON plan file
   - Cleans up temporary files

## Requirements

- Python must be available in the runner environment
- Terraform and Terragrunt must be installed before running this action
- AWS credentials or other provider authentication must be configured if required by your Terraform code

## Notes

- The action will generate Terraform plans using Terragrunt if they don't already exist
- Each subfolder should contain a valid terragrunt.hcl file
- The default compliance rules come from the terraform-compliance project's user-friendly-features repository
- For more information on writing custom compliance rules, see the [terraform-compliance documentation](https://terraform-compliance.com/pages/bdd-references/)