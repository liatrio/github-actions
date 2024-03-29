#!/bin/sh -l
set -e

# get old version
PREVIOUS_VERSION=$(yq e "$MANIFEST_PATH" $MANIFEST_FILE)

# increment version
NEXT_VERSION=$(node /semver-increment $PREVIOUS_VERSION $SEMVER_POSITION)

echo "Change version in $MANIFEST_FILE:$MANIFEST_PATH from $PREVIOUS_VERSION to $NEXT_VERSION"

# Change manifest value
yq e "$MANIFEST_PATH = \"$NEXT_VERSION\"" -i $MANIFEST_FILE
