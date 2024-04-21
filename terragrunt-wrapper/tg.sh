#!/usr/bin/env sh

set -e

EXIT_CODE=0
TERRAFORM_VERSION="${TERRAFORM_VERSION:-latest}"
TERRAGRUNT_VERSION="${TERRAGRUNT_VERSION:-latest}"
ARCH="${ARCH:-linux_amd64}"

TERRAGRUNT_SUB_COMMAND="$1"
TERRAGRUNT_WORKING_DIR="${2:-$TERRAGRUNT_WORKING_DIR}"
[ -n "$TERRAGRUNT_WORKING_DIR" ] && TERRAGRUNT_WORKING_DIR_FULL="$(realpath ${TERRAGRUNT_WORKING_DIR})"

# Define some variables
HELP_MESSAGE="sub commands:\n  - fmt\n  - install\n  - init\n  - plan\n  - apply"
TERRAFORM_PATH="${HOME}/.local/bin/terraform"
TERRAFORM_DIR="$(dirname ${TERRAFORM_PATH})"
TERRAGRUNT_PATH="${HOME}/.local/bin/terragrunt"
TERRAGRUNT_DIR="$(dirname ${TERRAGRUNT_PATH})"

# Get latest terraform version and build url if custom version is not set.
if [ -n "${TERRAFORM_VERSION}" ]; then
  if [ "${TERRAFORM_VERSION}" = "latest" ]; then
    TERRAFORM_URL="https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')_${ARCH}.zip"
  else
    TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${ARCH}.zip"
  fi
fi

# Get latest terraform version and build url if custom version is not set.
if [ -n "${TERRAGRUNT_VERSION}" ]; then
  if [ "${TERRAGRUNT_VERSION}" = "latest" ]; then
    TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/terragrunt_${ARCH}"
  else
    TERRAGRUNT_URL="https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_${ARCH}"
  fi
fi

init() {
  terragrunt init --terragrunt-working-dir="${TERRAGRUNT_WORKING_DIR_FULL}" -input=false
}

verify_checksum() {
  [ -n "${VERIFY_TOOL}" -a -f "${VERIFY_TOOL}" ] && \
    ${VERIFY_TOOL} "${1}" "${2}" "${3}"
}

downloader() {
  local url="$1"
  local checksum="$2"
  local checksum_command="$3"
  local name="$(basename $url)"
  local file_name="${4}"
  local curl_command="curl -Ls ${url} -o ${name}"

  printf "Downloading %s\nUsing command: %s\n" "${name}" "${curl_command}"
  
  $curl_command

  verify_checksum "${name}" "${checksum}" "${checksum_command}" || { printf "There was an issue verifying the checksum. Exiting ...\n" >&2; exit 1; }

  if [ $(file ${name} | grep -q 'zip' && echo 1 || echo 0) -eq 1 ]; then
    unzip "${name}" || { printf "File not found: %s\n" "${1}"; exit 1; }
  fi
  
  if [ -n "${file_name}" ]; then
    printf "Renaming '%s' to '%s'\n" "${name}" "${file_name}"
    mv "${name}" "${file_name}"
  fi

  echo "package-name=${name}" >> $GITHUB_OUTPUT
  echo "file-name=${file_name}" >> $GITHUB_OUTPUT
}

installer() {
  local target="$1"
  local file_name=$(basename $target)

  chmod +x "./${file_name}" || { printf "File not found: %s\n" "${file_name}"; exit 1; }

  printf "Moving './%s' to '%s' ...\n" "${file_name}" "${target}"
  mv "./${file_name}" "${target}"
}

uuid_gen() {
  if [ -n "$(which uname)" ]; then
    case $(uname -s) in
      "linux"|"Linux" )
        # https://serverfault.com/a/529319
        random_uuid=$(cat /proc/sys/kernel/random/uuid)
        ;;
      * )
        # https://serverfault.com/a/529319
        random_uuid="$(od -x /dev/urandom | head -1 | awk '{OFS="-"; srand($6); sub(/./,"4",$5); sub(/./,substr("89ab",rand()*4,1),$6); print $2$3,$4,$5,$6,$7$8$9}')"
        ;;
    esac
    echo "${random_uuid}"
  else
    echo "${RANDOM}"
  fi  
}

PLANFILE="$(uuid_gen).tfplan"

# Wrap around terragrunt
case $TERRAGRUNT_SUB_COMMAND in
  "install" )
    if [ ! -d "${TERRAFORM_DIR}" ]; then
        mkdir -p "${TERRAFORM_DIR}"
    fi
    if [ ! -f "${TERRAFORM_PATH}" ]; then
        downloader "${TERRAFORM_URL}" "${TERRAFORM_CHECKSUM}" "sha256sum" || { printf "There was a problem downloading %s. Exiting ...\n" "terraform" >&2; exit 1; }
        installer "${TERRAFORM_DIR}/terraform"
        printf "Installed %s: %s\n" "${TERRAFORM_DIR}/terraform" "$(terraform -v)"
        echo "${TERRAFORM_DIR}" >> $GITHUB_PATH
        echo "terraform-path=${TERRAFORM_DIR}" >> $GITHUB_OUTPUT
    fi
    if [ ! -f "${TERRAGRUNT_PATH}" ]; then
        downloader "${TERRAGRUNT_URL}" "${TERRAGRUNT_CHECKSUM}" "sha256sum" "terragrunt" || { printf "There was a problem downloading %s. Exiting ...\n" "terragrunt" >&2; exit 1; }
        installer "${TERRAFORM_DIR}/terragrunt"
        printf "Installed %s: %s\n" "${TERRAGRUNT_DIR}/terragrunt" "$(terragrunt -v)"
        echo "${TERRAGRUNT_DIR}" >> $GITHUB_PATH
        echo "terragrunt-path=${TERRAGRUNT_PATH}" >> $GITHUB_OUTPUT
    fi
    ;;
  "init" )
    # shift argument list "one to the left" to not call 'terragrunt init init'
    shift
    init "${@}"
    ;;
  "plan" )
    init
    printf "Creating planfile: %s\n" "${PLANFILE}"
    terragrunt plan -out $PLANFILE --terragrunt-working-dir="${TERRAGRUNT_WORKING_DIR_FULL}" -input=false -detailed-exitcode || EXIT_CODE=$?
    PLANFILE_REAL=$(find . -name $PLANFILE)
    echo "Finished Plan"

    [ -f $PLANFILE_REAL ] || { printf "Planfile not found: %s\n" "${PLANFILE}"; exit 1; }
    printf "Found planfile %s\n" "$(realpath ${PLANFILE})"
    terragrunt show -json "${PLANFILE}" > "${$PLANFILE}.json"

    echo "planfile=$(realpath ${PLANFILE})"
    echo "planfile=$(realpath ${PLANFILE})" >> $GITHUB_ENV
    echo "planfile-json=$(realpath ${PLANFILE}.json)"
    echo "planfile-json=$(realpath ${PLANFILE}.json)" >> $GITHUB_ENV
    ;;
  "apply" )
    init
    terragrunt apply --terragrunt-working-dir="${TERRAGRUNT_WORKING_DIR_FULL}" -auto-approve
    ;;
  "fmt" )
    init
    terragrunt fmt --terragrunt-working-dir="${TERRAGRUNT_WORKING_DIR_FULL}" -recursive
    ;;
  "planfile" )
    echo "planfile=$(realpath ${PLANFILE})"
    echo "planfile=$(realpath ${PLANFILE})" >> $GITHUB_OUTPUT
    ;;
  * )
    printf "%s\n" "${HELP_MESSAGE}"
esac