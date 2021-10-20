#!/bin/sh -l

ANDROID_FILENAME=$(basename "${ANDROID_FILE}")
IOS_FILENAME=$(basename "${IOS_FILE}")
echo "ANDROID_FILE: ${ANDROID_FILENAME}"
echo "IOS_FILE: ${IOS_FILENAME}"

AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

# Get the latest release id, store in temporary file
curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/liatrio/mobile-pipeline-poc/releases/latest > temp.json

RELEASE_ID=$(jq --raw-output '.id' "temp.json")
echo "RELEASE_ID: ${RELEASE_ID}"

tmp=${mktemp}

UPLOAD_URL="https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${ANDROID_FILENAME},${IOS_FILENAME}"
echo "UPLOAD_URL: ${UPLOAD_URL}"

#upload binary file to release with associated release id
# curl \
#         -sSL \
#         -XPOST \
#         -H "Authorization: token ${GITHUB_TOKEN}" \
#         --upload-file "${FILE}" \
#         --header "Content-Type:application/octet-stream" \
#         --write-out "%{http_code}" \
#         --output $tmp \
#         ${UPLOAD_URL}

pwd
ls

curl \
    -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type:application/zip" \
    --upload-file "${ANDROID_FILE}" \
    "https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${ANDROID_FILENAME}"

curl \
    -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type:application/zip" \
    --upload-file "${IOS_FILE}" \
    "https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${IOS_FILENAME}"
