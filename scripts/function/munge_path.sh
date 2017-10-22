# # scripts/function/munge_path.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_MUNGE_PATH:-} -eq 1 ]] && return || readonly GVM_MUNGE_PATH=1

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

# __gvm_munge_path()
# /*!
# @abstract Generate a new PATH with gvm and rvm elements in the correct order
# @discussion
# Scans path and Removes any existing elements that refer to the .gvm directory,
#   extracts and preserves elements that refer to the .rvm directory, preserves
#   all other elements. Builds a new PATH in this order:
#     * .rvm elements
#     * .gvm elements
#     * all other entries
#
#  The purpose of mungeing is to generate a new path dynamically so that user
#  changes to a PATH can be incorporated immediately.
# @param path [optional] Path to munge, defaults to $PATH
# @param dedupe [optional] Remove duplicates from the resulting output (true) or
#   leave them in place (false), defaults to true
# @return Returns a string containing munged path (status 0) or an empty string
#   (status 1) on failure.
# @note Also sets global variable RETVAL to the same return value.
# */
__gvm_munge_path() {
    local path_in="${1:-$PATH}"
    local path_in_ary; path_in_ary=()
    local path_out=""
    local path_out_ary; path_out_ary=()
    local path_dedupe_flag="${2:-true}"
    local rvm_regex='([^:\\\n\\\0]+[.]?rvm{1}[^:\\\n\\\0]+)'
    local rvm_ary; rvm_ary=()
    local gvm_regex='([^:\\\n\\\0]+[.]?gvm{1}[^:\\\n\\\0]+)'
    local gvm_ary; gvm_ary=()
    local general_ary; general_ary=()
    local defaultIFS="$IFS"
    local IFS="$defaultIFS"
    local spaceChar=$' '
    unset RETVAL

    [[ -z "${path_in// /}" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    # convert path into an array of elements, encode spaces
    IFS=':' path_in_ary=( ${path_in//$spaceChar/%2f} ) IFS="$defaultIFS"

    # extract path elements
    local _path
    for _path in "${path_in_ary[@]}"
    do
        if [[ "${_path}" =~ $gvm_regex ]]
        then
            # echo "matched (gvm): ${_path}"
            gvm_ary+=(${_path})
        elif [[ "${_path}" =~ $rvm_regex ]]
        then
            # echo "matched (rvm): ${_path}"
            rvm_ary+=(${_path})
        else
            general_ary+=(${_path})
        fi
    done
    unset _path

    # assemble path array
    path_out_ary=( ${rvm_ary[@]} ${gvm_ary[@]} ${general_ary[@]} )

    # deduplicate path_out_ary if requested, do this just to be helpful :)
    if [[ "${path_dedupe_flag}" == true ]]
    then
        local _dedupe_path_out_ary; _dedupe_path_out_ary=()
        for (( i=0; i<${#path_out_ary[@]}; i++ ))
        do
            local __element="${path_out_ary[i]}"
            [[ -n "${__element}" ]] && _dedupe_path_out_ary+=( "${__element}" )
            # reset duplicates to an empty string so we can ignore them
            for (( j=${#path_out_ary[@]}-1; j>i; j-- ))
            do
                [[ "${__element}" == "${path_out_ary[j]}" ]] && path_out_ary[j]=""
            done
            unset __element
        done
        path_out_ary=( ${_dedupe_path_out_ary[@]} )
        unset _dedupe_path_out_ary
    fi

    # convert path elements array into path string, decode spaces
    IFS=":" path_out="${path_out_ary[*]}" IFS="$defaultIFS"

    RETVAL="${path_out//%2f/$spaceChar}"

    if [[ -z "${RETVAL// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}
