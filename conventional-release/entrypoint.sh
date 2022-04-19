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

previousVersion=$(git describe --tags --abbrev=0)
output "previousVersion" "${previousVersion}"

/action/node_modules/semantic-release/bin/semantic-release.js "${flags[@]}"

newVersion=$(git describe --tags --abbrev=0)
output "newVersion" "${newVersion}"

changed="true"

if [ "$previousVersion" == "$newVersion" ]; then
  changed="false"
fi

output "changed" "${changed}"
