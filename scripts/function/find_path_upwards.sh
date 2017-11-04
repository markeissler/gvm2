# scripts/function/find_path_upwards.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_FIND_PATH_UPWARDS:-} -eq 1 ]] && return || readonly GVM_FIND_PATH_UPWARDS=1

# load dependencies
dep_load() {
    local srcd="${BASH_SOURCE[0]}"; srcd="${srcd:-${(%):-%x}}"
    local base="$(builtin cd "$(dirname "${srcd}")" && builtin pwd)"
    local deps; deps=(
        "_shell_compat.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load; unset -f dep_load &> /dev/null || unset dep_load

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
    local start_dir=""
    {
        __gvm_pwd > /dev/null
        start_dir="${2:-$RETVAL}"
    }
    local final_dir="${3:-$HOME}"
    unset RETVAL

    if [[ \
        -z "${target// /}" || \
        -z "${start_dir// /}" || \
        -z "${final_dir// /}"
        ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    # WSL: PWD can either be in linux (root dir is /) or in Windows (root dir is
    # /mnt/c). We can get the actual PWD to check where we are, if within /mnt,
    # then a reasonable final_dir (the user's Windows HOME directory) is within
    # /mnt/c/Users/USERNAME. Unfortunately, there is no way to know the USERNAME
    # as the user can have a different account name for the linux install. So,
    # we will stop looking at /mnt/c/Users.
    #
    local fwd_slash_char=$'/' # @TODO: need _shell_compat escape function!
    local wsl_rootdir_regex="^\/mnt\/c\/"
    local linux_homedir_regex="^${HOME//$fwd_slash_char/\\/}"
    if __gvm_rematch "${start_dir}" "${wsl_rootdir_regex}" &&
        __gvm_rematch "${final_dir}" "${linux_homedir_regex}"
    then
        final_dir="/mnt/c/Users"
    fi

    # NOTE: This call has to be made in a forked shell, otherwise the current
    # PWD will become corrupted.
    RETVAL="$(__gvmp_find_path_for_target "${target}" "${start_dir}" "${final_dir}")"

    if [[ -z "${RETVAL// /}" ]]
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
