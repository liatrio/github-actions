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

currentVersion=$(git describe --tags --abbrev=0)
output "currentVersion" "${currentVersion}"

npx semantic-release "${flags[@]}"

newVersion=$(git describe --tags --abbrev=0)
output "newVersion" "${newVersion}"

changed="true"

if [ "$currentVersion" == "$newVersion" ]; then
  changed="false"
fi

output "changed" "${changed}"
