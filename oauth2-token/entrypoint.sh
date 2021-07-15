#!/usr/bin/env bash

set -euo pipefail

flags=(
  --user ${CLIENT_ID}:${CLIENT_SECRET}
  -d "grant_type=client_credentials"
)

if [ "${SCOPES}" ]; then
  flags+=(--data-urlencode "scope=${SCOPES}")
fi

response=$(curl "${flags[@]}" ${TOKEN_URL})

if [ "$(echo "$response" | jq 'has("error")')" == 'true' ]; then
  echo "Error retrieving token: ${response}"
  exit 1
fi

token=$(echo "${response}" | jq -r '.access_token | values')

if [ -z "${token}" ]; then
  echo "Response does not contain access token"
  exit 1;
fi

echo "::add-mask::${token}"
echo "::set-output name=accessToken::${token}"
