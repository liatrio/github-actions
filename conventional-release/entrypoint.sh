#!/usr/bin/env bash

set -euo pipefail

function output {
  echo "::set-output name=${1}::${2}"
}

flags=(--ci)

if [ "${DRY_RUN}" ]; then
  flags+=(--dry-run)
fi

if [ "${DEBUG}" ]; then
  flags+=(--debug)
fi

#Check to see if a previous tag exists
if previousVersion=$(git describe --tags --abbrev=0 2>/dev/null); then
  echo "A previous tag was found"
  output "previousVersion" "${previousVersion}"
else
  echo "A previous tag was not found"
fi

$GITHUB_ACTION_PATH/node_modules/semantic-release/bin/semantic-release.js "${flags[@]}"

newVersion=$(git describe --tags --abbrev=0)
output "newVersion" "${newVersion}"

changed="true"

if [ "$previousVersion" == "$newVersion" ]; then
  changed="false"
fi

output "changed" "${changed}"
