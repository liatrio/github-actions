#!/bin/sh -l
set -e

# get old value
PREVIOUS_VALUE=$(yq r $MANIFEST_FILE $MANIFEST_PATH)

echo "Change value in $MANIFEST_FILE:$MANIFEST_PATH from $PREVIOUS_VALUE to $VALUE"

# Change manifest value
yq w -i $MANIFEST_FILE $MANIFEST_PATH $VALUE