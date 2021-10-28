#!/bin/sh -l

FILENAME=$(basename "${FILE}")
echo "FILE: ${FILENAME}"
echo "OWNER: ${OWNER}"
echo "GITHUB_REPOSITORY: ${GITHUB_REPOSITORY}"
# Get the latest release id, store in temporary file
curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/liatrio/mobile-pipeline-poc/releases/latest > temp.json

cat temp.json

RELEASE_ID=$(jq --raw-output '.id' "temp.json")
echo "RELEASE_ID: ${RELEASE_ID}"


UPLOAD_URL="https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${FILENAME}"
echo "UPLOAD_URL: ${UPLOAD_URL}"

curl \
    -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type:application/octet-stream" \
    --upload-file "${FILE}" \
    ${UPLOAD_URL} 
