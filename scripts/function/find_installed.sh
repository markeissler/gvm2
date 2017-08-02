# scripts/function/find_installed.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_FIND_INSTALLED:-} -eq 1 ]] && return || readonly GVM_FIND_INSTALLED=1

# load dependencies
dep_load() {
    local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"
    local deps; deps=(
        "_bash_pseudo_hash.sh"
        "read_environment_file.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load

# __gvm_find_installed()
# /*!
# @abstract Find all installed versions of go.
# @discussion
# Searches the installed_path specified or $GVM_ROOT/gos directory; resolves
#   the system installed go if it exists.
# @param target [optional] Go version to find
# @param installed_path [optional] Go install path (directory to installed gos)
# @return Returns a pseudo hash where keys are Go versions and values are paths
#   to Go version installations (status 0) or an empty string (status 1) on
#   failure.
# @note Also sets global variable RETVAL to the same return value.
# */
__gvm_find_installed()
{
    local target="${1}"; shift
    local installed_path="${1:-$GVM_ROOT/gos}"
    local installed_hash; installed_hash=()
    local versions_hash; versions_hash=()
    unset RETVAL

    [[ ! -d "${installed_path}" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    if [[ -z "${target}" ]]
    then
        installed_hash=( $("${LS_PATH}" -1 "${installed_path}") )
        for (( i=0; i<${#installed_hash[@]}; i++ ))
        do
            local __key __val
            __key="${installed_hash[i]}"
            __val="${installed_path}/${__key}"

            # system is a special case
            if [[ "${__key}" == "system" ]]
            then
                # resolve path from environment!
                local system_env="$( __gvm_read_environment_file "${GVM_ROOT}/environments/system")"
                __val="$(valueForKeyFakeAssocArray "GOROOT" "${system_env[*]}")"
                unset system_env
            fi

            versions_hash=( $(setValueForKeyFakeAssocArray "${__key}" "${__val}" "${versions_hash[*]}") )
            unset __key __val
        done
    else
        if [[ -d "${installed_path}/${target}" ]]
        then
            local __key __val
            __key="${target}"
            __val="${installed_path}/${__key}"
            versions_hash=( $(setValueForKeyFakeAssocArray "${__key}" "${__val}" "${versions_hash[*]}") )
            unset __key __val
        fi
    fi

    if [[ ${#versions_hash[@]} -eq 0 ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    RETVAL="${versions_hash[*]}"

    echo "${RETVAL}" && return 0
}
