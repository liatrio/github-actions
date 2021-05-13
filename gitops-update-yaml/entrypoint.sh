#!/bin/sh -l
set -e

# get old value
PREVIOUS_VALUE=$(yq e "$MANIFEST_PATH" $MANIFEST_FILE)

echo "Change value in $MANIFEST_FILE:$MANIFEST_PATH from $PREVIOUS_VALUE to $VALUE"

# Change manifest value
yq e "$MANIFEST_PATH = \"$VALUE\"" -i $MANIFEST_FILE