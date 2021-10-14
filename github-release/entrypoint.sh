#!/bin/sh -l

curl \
  -X POST \
  -H "Authorization: $TOKEN_NAME $PAT" \
  https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases \
  -d "{\"tag_name\":\"$TAG_NAME\"}"
  