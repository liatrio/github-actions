#!/bin/sh -l

FILENAME=$(basename "${FILE}")

AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

RELEASE_ID=$(jq --raw-output '.release.id' "$GITHUB_EVENT_PATH")

tmp=${mktemp}

UPLOAD_URL="https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${FILENAME}"
curl \
        -sSL \
        -XPOST \
        -H "${AUTH_HEADER}" \
        --upload-file "${FILE}" \
        --header "Content-Type:application/octet-stream" \
        --write-out "%{http_code}" \
        --output $tmp \
        "${UPLOAD_URL}"