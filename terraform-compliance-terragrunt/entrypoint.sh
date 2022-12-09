#!/usr/bin/env bash

set -e

if [ -n "$GH_PAT" ]; then
  git config --global url."https://${GITHUB_ACTOR}:${GH_PAT}@github.com".insteadOf ssh://git@github.com
fi

export TARGET_FOLDER="${TARGET_FOLDER:-.}"
export SUBFOLDERS="${SUBFOLDERS:-.}"
export SUBFOLDERS=($SUBFOLDERS)

# Use $RANDOM to avoid naming collisions
export RANDOM_PLAN_FILE="${RANDOM}_${PLAN_FILE}"
command_opts=(
 -p "${RANDOM_PLAN_FILE}"
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
  terragrunt plan -lock=false --out plan.out
  terragrunt show -json plan.out > "${RANDOM_PLAN_FILE}"
  printf "Running '%s' ...\n" "${COMPLIANCE_COMMAND} ${COMPLIANCE_COMMAND_OPTS[@]}"
  ${COMPLIANCE_COMMAND} ${COMPLIANCE_COMMAND_OPTS[@]}
  echo "##################################################################################################################"
  rm "${RANDOM_PLAN_FILE}"
  popd
done