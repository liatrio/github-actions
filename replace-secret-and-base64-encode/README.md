# Replace Secret and Base64 Encode

A GitHub Action that replaces sensitive tokens in a file with a random placeholder and then base64 encodes the result. This action is useful for securely handling files containing sensitive information in CI/CD workflows.

## Description

The `replace-secret-and-base64-encode` action takes a file that contains a sensitive token (like an API key or password), replaces that token with a randomly generated string, and then base64 encodes the entire file. This approach allows you to:

1. Remove sensitive information from files before storing or transmitting them
2. Keep a record of where the sensitive information was located (via the replacement key)
3. Use the base64-encoded content in subsequent workflow steps

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `token` | The sensitive token/string to be replaced | Yes | - |
| `file` | The path to the file containing the sensitive token | Yes | - |
| `replace-key-entropy` | The entropy value for generating the replacement key (passed to `openssl rand -hex`) | No | `8` |

## Outputs

| Output | Description |
|--------|-------------|
| `base64-encoded` | The base64-encoded content of the file with the token replaced |
| `replacement-key` | The randomly generated string that replaced the sensitive token |

## Usage

### Basic Example

```yaml
jobs:
  process-sensitive-file:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Replace Secret and Encode
        id: encode
        uses: liatrio/github-actions/replace-secret-and-base64-encode@main
        with:
          token: ${{ secrets.API_KEY }}
          file: ./config/credentials.json
      
      - name: Use Encoded Content
        run: |
          echo "Encoded content: ${{ steps.encode.outputs.base64-encoded }}"
          echo "Replacement key: ${{ steps.encode.outputs.replacement-key }}"
          
          # Example: Decode the content for verification
          echo "${{ steps.encode.outputs.base64-encoded }}" | base64 -d
```

### Advanced Example with Custom Entropy

```yaml
- name: Replace Secret with Higher Entropy
  id: encode
  uses: liatrio/github-actions/replace-secret-and-base64-encode@main
  with:
    token: ${{ secrets.DATABASE_PASSWORD }}
    file: ./database/connection.yaml
    replace-key-entropy: "16"  # Generate a longer replacement key
```

## How It Works

1. The action generates a random hexadecimal string using `openssl rand -hex`
2. It reads the specified file and replaces all occurrences of the sensitive token with this random string
3. The modified content is then base64 encoded
4. Both the base64-encoded content and the replacement key are provided as outputs

## Security Considerations

- The original sensitive token is never output or logged
- The replacement is done before base64 encoding to ensure the sensitive data is not present in the encoded output
- The random replacement key is generated with cryptographically secure randomness via OpenSSL
- Consider the security implications of where you store or use the base64-encoded output

## Use Cases

- Preparing configuration files for deployment while removing sensitive credentials
- Creating Kubernetes secrets from files containing sensitive information
- Storing sanitized versions of configuration files in logs or artifacts
- Transmitting configuration templates that originally contained sensitive data
