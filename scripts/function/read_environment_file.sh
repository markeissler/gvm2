# scripts/function/read_environment_file.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_READ_ENVIRONMENT_FILE:-} -eq 1 ]] && return || readonly GVM_READ_ENVIRONMENT_FILE=1

# load dependencies
dep_load() {
    local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"
    local deps; deps=(
        "_bash_pseudo_hash.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load; unset -f dep_load

# __gvm_read_environment_file()
# /*!
# @abstract Read and parse a gvm environment file
# @discussion
# Reads the gvm environment file at specified path. Parses the file and returns
#   a bash_pseudo_hash containing key/val pairs.
#
# It is expected that the file format consists of lines conforming to the
# following pattern:
# <pre>@textblock
#   # this is a comment line
#   export gvm_pkgset_name; gvm_pkgset_name="global"
# @/textblock</pre>
#
# In the above example, everything is discarded before the final key=val part,
# which is parsed and stored in the resulting hash. Comment lines (beginning
# with a '#' character) will be ignored.
# @param path Path to environment file
# @return Returns a bash_pseudo_hash containing parsed key/val pairs (status 0)
#   or an empty string (status 1) on failure.
# @note Also sets global variable RETVAL to the same return value.
# */
__gvm_read_environment_file() {
    local filepath="${1}"
    local regex='^export ([^[:digit:]]+[[:alnum:]_]+);[[:space:]]*([^[:digit:]]+[[:alnum:]_]+=(.*))$'
    local hash; hash=()
    unset RETVAL

    if [[ -z "${filepath// /}" || ! -r "${filepath}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    while IFS=$'\n' read -r _line; do
        local __key __val
        # skip comment lines
        [[ "${_line}" =~ \#.* ]] && continue

        # each parseable line follows this format:
        #   export VAR; VAR="VALUE"
        if [[ "${_line}" =~ ${regex} ]]
        then
            __key="${BASH_REMATCH[1]}"
            __val="${BASH_REMATCH[3]#\"}"
            # strip leading and trailing quotes
            __val=${__val#\"}; __val=${__val%\"}
            # add to pseudo-hash
            hash=( $(setValueForKeyFakeAssocArray "${__key}" "${__val}" "${hash[*]}") )
        fi
        unset __key __val
    done <<< "$(cat "${filepath}")"

    if [[ ${#hash[@]} -eq 0 ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    RETVAL="${hash[*]}"

    echo "${RETVAL}" && return 0
}
