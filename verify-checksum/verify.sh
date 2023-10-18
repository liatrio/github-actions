#!/usr/bin/env sh

set -e

EXIT_CODE=0
HELP_MESSAGE="Invalid usage"
ERROR_MESSAGE="Verification encountered an error"

err() {
    # [ $EXIT_CODE -eq 0 ] && EXIT_CODE= && unset EXIT_CODE
    DEFAULT_EXIT_CODE=${EXIT_CODE:-1}
    EXIT_CODE=${2:-$DEFAULT_EXIT_CODE}
    if [ "$EXIT_CODE" != "0" ]; then
        printf "%s. Error code %s ...\n" "${1:-$ERROR_MESSAGE}" ${EXIT_CODE} >&2
    fi
    return $EXIT_CODE
}
errex() {
    err "$@" || { 
        local err_code=$?
        printf "Exiting with code %d ...\n" $err_code
        exit $err_code
    }
}

[ -n "$1" -a -n "$2" ] || { errex "${HELP_MESSAGE}. At least 2 arguments required"; }

FILENAME="${1}"
CHECKSUM="${2}"
if [ -f "${CHECKSUM}" ]; then
    CHECKSUM_FILE="$(realpath ${CHECKSUM})"
    CHECKSUM="$(cat ${CHECKSUM_FILE})"
    printf "Checksum '%s' is a file\n" "${CHECKSUM_FILE}"
else
    CHECKSUM_VAL=$(echo ${CHECKSUM} | awk -F' ' '{ print $1 }')
    printf "Checksum '%s' is a value\n" "${CHECKSUM_VAL}"
fi

generate_compare() {
    echo "${1}  ${2}"
}

VERIFICATION_RESULT=
verify_sha256sum() {
    local compare="${2}"
    [ -n "${3}" -a "${3}x" != "x" ] && compare="$(generate_compare ${3} ${1})"
    VERIFICATION_RESULT=$(echo "${compare}" | grep "${1}" --color=never | sha256sum -c -) || { EXIT_CODE=$?; err "Actual value '$(sha256sum ${1})' does not matched expected value"; }
    [ $EXIT_CODE -eq 0 ] || return $EXIT_CODE
}

CHECKSUM_COMMAND=
CHECKSUM_VALIDATOR=
case "${3}" in
    "sha256sum" )
        CHECKSUM_COMMAND="${3}"
        CHECKSUM_VALIDATOR="verify_sha256sum"
        ;;
    * )
        errex "Invalid validation function"
        ;;
esac

if [ -n "${CHECKSUM_FILE}" ]; then
    printf "Expected checksum file contents:\n%s\n" "${CHECKSUM}"
elif [ -n "${CHECKSUM_VAL}" ]; then
    printf "Expected checksum value: %s\n" "${CHECKSUM}"
else
    errex "There was a problem"
fi

printf "Veryfying %s using %s ...\n" "${FILENAME}" "${CHECKSUM_COMMAND}"

${CHECKSUM_VALIDATOR} "${FILENAME}" "${CHECKSUM}" "${CHECKSUM_VAL}" && \
    printf "\033[%d;1m%s\033[0m\n" 92 "$VERIFICATION_RESULT" || \
    { printf "\033[%d;1m%s\033[0m\n" 91 "$VERIFICATION_RESULT"; err "The function '${CHECKSUM_VALIDATOR}' encountered an error"; }

[ $EXIT_CODE -eq 0 ] || exit $EXIT_CODE