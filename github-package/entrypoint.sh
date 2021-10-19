#!/bin/sh -l

FILENAME=$(basename "${FILE}")
echo "FILE: ${FILE}"

AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

echo "GITHUB_EVENT_PATH: $GITHUB_EVENT_PATH"

RELEASE_ID=$(jq --raw-output '.release.id' "$GITHUB_EVENT_PATH")
echo "RELEASE_ID: ${RELEASE_ID}"

tmp=${mktemp}

UPLOAD_URL="https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${FILENAME}"
echo "UPLOAD_URL: ${UPLOAD_URL}"


curl \
        -sSL \
        -X POST \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        --upload-file "${FILE}" \
        --header "Content-Type:application/octet-stream" \
        --write-out "%{http_code}" \
        --output $tmp \
        "${UPLOAD_URL}"