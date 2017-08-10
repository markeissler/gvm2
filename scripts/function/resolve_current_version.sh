# scripts/function/resolve_current_version.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_RESOLVE_CURRENT_VERSION:-} -eq 1 ]] && return || readonly GVM_RESOLVE_CURRENT_VERSION=1

# load dependencies
dep_load() {
    local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"
    local deps; deps=(
        "_shell_compat.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load

# __gvm_resolve_current_version()
# /*!
# @abstract Determine the currently active go version name
# @discussion
# This function will call the currently active go (resolved via regular PATH
#   resolution) with the version command. The returned string will be parsed and
#   the essential go version name (e.g. go1.9.2, go1.9beta1) will be returned.
# <pre>@textblock
#   goM.m[.p][betaX|rcX]
#   M - Major version
#   m - minor version
#   p - patch version
# @/textblock</pre>
#   From the list of names that conform to the above pattern, the name with the
#   highest version number will be selected.
# @param path [optional] A search path, defaults to PATH.
# @return Returns a string containing the current version name (status 0) or an
#   empty string (status 1) on failure.
# @note Also sets global variable RETVAL to the same return value.
# */
__gvm_resolve_current_version() {
    local path="${1:-$PATH}"
    local active_go="$(PATH="${path}" which go)"
    local regex='(go([0-9]+(\.[0-9]+)*)([a-z0-9]*))'
    unset RETVAL

    [[ -z "${active_go// /}" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    while IFS=$'\n' read -r _line; do
        if __gvm_rematch "${_line}" "${regex}"
        then
            # GVM_REMATCH[1]: version name (e.g. go1.7.1, go1.9beta1, go1.7rc1)
            # GVM_REMATCH[2]: isolated version (e.g. 1.7.1)
            # GVM_REMATCH[3]: not used
            # GVM_REMATCH[4]: isolated betaX, rcX string
            version="${GVM_REMATCH[1]}"
        fi
    done <<< "$("${active_go}" version)"

    RETVAL="${version}"

    if [[ -z "${RETVAL// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}
