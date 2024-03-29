#!/bin/sh -l

FILENAME=$(basename "${FILE}")

# Get the latest release id, store in temporary file
curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/${ORG_OWNER}/${REPO}/releases/${RELEASE} > temp.json


RELEASE_ID=$(jq --raw-output '.id' "temp.json")
echo "RELEASE_ID: ${RELEASE_ID}"


UPLOAD_URL="https://uploads.github.com/repos/${ORG_OWNER}/${REPO}/releases/${RELEASE_ID}/assets?name=${FILENAME}"
echo "UPLOAD_URL: ${UPLOAD_URL}"

curl \
    -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type:application/octet-stream" \
    --upload-file "${FILE}" \
    ${UPLOAD_URL} \
    --fail
