#!/usr/bin/env bash

set -eo pipefail

if ${GITCONFIG_ENABLED:-false} 2>/dev/null ; then
  export GITCONFIG="${HOME}/.gitconfig"

  if [ ! -f "${GITCONFIG}" -a -n "${GITCONFIG_BASE64}" ]; then
    printf "Decoding gitconfig and saving to '%s' ...\n" "${GITCONFIG}"
    echo "${GITCONFIG_BASE64}" | base64 --decode --ignore-garbage | sed "s/${GITCONFIG_BASE64_KEY}/${GH_PAT}/g" > "${GITCONFIG}"
  fi

  if [ -f "${GITCONFIG}" ]; then
    contents=$(echo $(cat "${GITCONFIG}"))
    if [ -z "$contents" ]; then
      printf "File '%s' is empty. Removing ...\n" "${GITCONFIG}"
      rm -f "${GITCONFIG}"
    fi
  fi

  if [ ! -f "${GITCONFIG}" -a -n "${GH_PAT}" ]; then
    printf "Creating global gitconfig at '%s' ...\n" "${GITCONFIG}"
    git config --global url."https://${GITHUB_ACTOR}:${GH_PAT}@github.com".insteadOf ssh://git@github.com
  fi
fi

export TARGET_FOLDER="${TARGET_FOLDER:-.}"
export SUBFOLDERS="${SUBFOLDERS:-.}"
export SUBFOLDERS=($SUBFOLDERS)

# Use $RANDOM to avoid naming collisions
export RANDOM_PLAN_FILE="${PLAN_FILE}.${RANDOM}"
export RANDOM_PLAN_FILE_JSON="${RANDOM_PLAN_FILE}.json"
command_opts=(
 -p "${RANDOM_PLAN_FILE_JSON}"
 -f "${COMPLIANCE_FEATURES}"
)
for param in "${COMPLIANCE_COMMAND_OPTS[@]}"; do command_opts+=($param); done
export COMPLIANCE_COMMAND_OPTS="${command_opts[@]}"
export COMPLIANCE_COMMAND=terraform-compliance

cd $TARGET_FOLDER

printf "Current Target: %s\n" "$(pwd)"

for folder in "${SUBFOLDERS[@]}"; do
  fulldir="${TARGET_FOLDER}/${folder}"
  echo "##################################################################################################################"
  echo "TERRAFORM COMPLIANCE PATH ${fulldir}"
  echo "##################################################################################################################"
  pushd $folder
  printf "Current Subfolder: %s\n" "$(pwd)"
  ls -l
  [ -f "${PLAN_FILE}" ] || terragrunt plan -lock=false --out "${PLAN_FILE}"
  printf "Renaming '%s' to '%s' ...\n" "${PLAN_FILE}" "${RANDOM_PLAN_FILE}"
  mv "${PLAN_FILE}" "${RANDOM_PLAN_FILE}"
  printf "Creating json planfile '%s' ...\n" "${RANDOM_PLAN_FILE_JSON}"
  terragrunt show -json "${RANDOM_PLAN_FILE}" > "${RANDOM_PLAN_FILE_JSON}"
  printf "Running '%s' ...\n" "${COMPLIANCE_COMMAND} ${COMPLIANCE_COMMAND_OPTS[@]}"
  ${COMPLIANCE_COMMAND} ${COMPLIANCE_COMMAND_OPTS[@]}
  echo "##################################################################################################################"
  rm "${RANDOM_PLAN_FILE_JSON}"
  popd
done