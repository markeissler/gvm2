# scripts/function/find_local_pkgset.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_FIND_LOCAL_PKGSET:-} -eq 1 ]] && return || readonly GVM_FIND_LOCAL_PKGSET=1

# load dependencies
dep_load() {
    local srcd="${BASH_SOURCE[0]}"; srcd="${srcd:-${(%):-%x}}"
    local base="$(builtin cd "$(dirname "${srcd}")" && builtin pwd)"
    local deps; deps=(
        "find_path_upwards.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load; unset -f dep_load &> /dev/null || unset dep_load

# __gvm_find_local_pkgset()
# /*!
# @abstract Search upwards through the directory tree for a local pkgset and
#   returns the path to the first instance found
# @discussion
# Searches upwards through the directory tree starting at start_dir for a local
#   pkgset directory (.gvm_local).
# @param start_dir [optional] Path to starting directory of search, defaults to
#   present working directory.
# @param final_dir [optional] Path to ending directory of search (that is the
#   highest directory in the tree that will be checked), defaults to user home
#   directory.
# @return Returns a string containing path of found pkgset directory (status 0)
#   or an empty string (status 1) on failure.
# @note Also sets global variable RETVAL to the same return value.
# */
__gvm_find_local_pkgset()
{
    local start_dir="${1:-$PWD}"
    local final_dir="${2:-$HOME}"
    unset RETVAL

    if [[ \
        "x${start_dir// /}" == "x" || \
        "x${final_dir// /}" == "x"
        ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    __gvm_find_path_upwards ".gvm_local" "${start_dir}" "${final_dir}" > /dev/null

    if [[ -z "${RETVAL// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}
