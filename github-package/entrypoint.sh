#!/bin/sh -l

FILENAME=$(basename "${FILE}")
echo "FILE: ${FILE}"

AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

# Get the latest release id, store in temporary file
curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/liatrio/mobile-pipeline-poc/releases/latest > temp.json

RELEASE_ID=$(jq --raw-output '.id' "temp.json")
echo "RELEASE_ID: ${RELEASE_ID}"

tmp=${mktemp}

UPLOAD_URL="https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${FILENAME}"
echo "UPLOAD_URL: ${UPLOAD_URL}"

#upload binary file to release with associated release id
curl \
        -sSL \
        -XPOST \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        --upload-file "${FILE}" \
        --header "Content-Type:application/octet-stream" \
        --write-out "%{http_code}" \
        --output $tmp \
        ${UPLOAD_URL}