# scripts/function/resolve_fallback_version.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_RESOLVE_FALLBACK_VERSION:-} -eq 1 ]] && return || readonly GVM_RESOLVE_FALLBACK_VERSION=1

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
}; dep_load; unset -f dep_load

# __gvm_resolve_fallback_version()
# /*!
# @abstract Determine a fallback version of go
# @discussion
# When normal go version resolution fails the fallback function will attempt to
#   find a suitable fallback from the installed go versions.
#
#   The fallback resolution process assumes that both "default" and "system"
#   environments have been sought first and will be discarded (if they exist)
#   from the fallback resolution process. Only go version names that match the
#   following pattern will be considered:
# <pre>@textblock
#   goM.m[.p]
#   M - Major version
#   m - minor version
#   p - patch version
# @/textblock</pre>
#   From the list of names that conform to the above pattern, the name with the
#   highest version number will be selected.
# @return Returns a string containing the fallback version name (status 0) or an
#   empty string (status 1) on failure.
# @note Also sets global variable RETVAL to the same return value.
# */
__gvm_resolve_fallback_version() {
    local version=""
    local regex='^([[:space:]]*[=>*]*[[:space:]]+)(go([0-9]+(\.[0-9]+)*))$'
    unset RETVAL

    while IFS=$'\n' read -r _line; do
        if __gvm_rematch "${_line}" "${regex}"
        then
            # GVM_REMATCH[1]: indicator (e.g. ' ', '*', '=>', '=*')
            # GVM_REMATCH[2]: version name (e.g. go1.7.1)
            # GVM_REMATCH[3]: isolated version (e.g. 1.7.1)
            version="${GVM_REMATCH[2]}"
        fi
    done <<< "$(\gvm list --porcelain)"

    RETVAL="${version}"

    if [[ -z "${RETVAL// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}
