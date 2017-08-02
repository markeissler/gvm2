# scripts/function/find_path_upwards.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_FIND_PATH_UPWARDS:-} -eq 1 ]] && return || readonly GVM_FIND_PATH_UPWARDS=1

# load dependencies
dep_load() {
    local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"
    local deps; deps=(
        "_shell_compat.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load

# __gvm_find_path_upwards()
# /*!
# @abstract Search upwards through the directory tree for a target file or
#   directory and return the path to the first instance found
# @discussion
# Searches upwards through the directory tree starting at start_dir for a target
#   file or directory basename.
# @param target Basename of file or directory to find
# @param start_dir [optional] Path to starting directory of search, defaults to
#   present working directory.
# @param final_dir [optional] Path to ending directory of search (that is the
#   highest directory in the tree that will be checked), defaults to user home
#   directory.
# @return Returns a string containing path of found file or directory (status 0)
#   or an empty string (status 1) on failure.
# @note Also sets global variable RETVAL to the same return value.
# */
__gvm_find_path_upwards()
{
    local target="${1}"
    local start_dir="${2:-$PWD}"
    local final_dir="${3:-$HOME}"
    unset RETVAL

    if [[ \
        "x${target// /}" == "x" || \
        "x${start_dir// /}" == "x" || \
        "x${final_dir// /}" == "x"
        ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    __gvmp_find_path_for_target "${target}" "${start_dir}" "${final_dir}" > /dev/null

    if [[ -z "${RETVAL}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}

__gvmp_find_path_for_target()
{
    local target="${1}"
    local start_dir="${2}"
    local final_dir="${3}"
    unset RETVAL

    [[ "x${target// /}" == "x" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    # resolve tilde for HOME
    start_dir="${start_dir/#\~/$HOME}"

    # resolve dot for PWD
    if [[ "${start_dir}" == "." ]]
    then
        start_dir="$(builtin pwd)"
    fi

    local current_dir="${start_dir}"
    local highest_dir="${final_dir}"

    builtin cd "${current_dir}"
    while [[ $? -eq 0 ]]
    do
        current_dir="$(builtin pwd)"

        if [[ -f "${current_dir}/${target}" ||  -d "${current_dir}/${target}" ]]
        then
            RETVAL="${current_dir}/${target}"
            echo "${RETVAL}" && return 0
        fi

        if [[ "${current_dir}" == "${highest_dir}" || "${current_dir}" == "/" ]]
        then
            break
        fi

        builtin cd ..
    done

    RETVAL="" && echo "${RETVAL}" && return 1
}
