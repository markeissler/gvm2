# scripts/function/find_available.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_FIND_AVAILABLE:-} -eq 1 ]] && return || readonly GVM_FIND_AVAILABLE=1

# load dependencies
dep_load() {
    local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"
    local deps; deps=(
        "_bash_pseudo_hash"
        "_shell_compat"
        "tools"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load

# __gvm_find_available()
# /*!
# @abstract Find available versions of go for a target platform.
# @discussion
# Retrieves list of available versions of go from a download source
# @param source Url of download source.
# @return Returns a pseudo hash where keys are Go versions and values are
#   download urls (status 0) or an empty string (status 1) on failure.
# */
__gvm_find_available()
{
    local url="${1}"; shift
    local versions_hash; versions_hash=()
    local regex='^(go([0-9]+(\.[0-9]+[a-z0-9]*)*))$'

    [[ "x${url}" != "x" ]] || (echo "" && return 1)

    while IFS=$'\n' read -r _line; do
        if __gvm_rematch "${_line}" "${regex}"
        then
            local __key __val
            # GVM_REMATCH[1]: version name (e.g. go1.7.1)
            # GVM_REMATCH[2]: isolated version (e.g. 1.7.1)
            __key="${GVM_REMATCH[1]}"
            __val="${url}"
            versions_hash=( $(setValueForKeyFakeAssocArray "${__key}" "${__val}" "${versions_hash[*]}") )
            unset __key __val
        fi
    done <<< "$(\git ls-remote -t "${url}" | awk -F/ '{ print $NF }' | $SORT_PATH)"

    if [[ ${#versions_hash[@]} -eq 0 ]]
    then
        unset versions_hash
        echo "" && return 1
    fi

    printf "%s" "${versions_hash[*]}"

    unset versions_hash
    return 0
}