# scripts/function/environment_sanitize.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_ENVIRONMENT_SANITIZE:-} -eq 1 ]] && return || readonly GVM_ENVIRONMENT_SANITIZE=1

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

# __gvm_environment_sanitize()
# /*!
# @abstract Repair the system and system@global environments
# @discussion
# The system and system@global environments are created when GVM2 is installed
#   and settings are determined from an existing system-install of Go (usually,
#   in the /usr/local directory). If the system-install is later changed (either
#   during a routine update or manually) then these environments will likely
#   break as PATHs become stale.
#
#   This function will attempt to find the current system-install of Go and make
#   corrections to the system and system@global environments if needed.
# @note Only the system and system@global environments are currently supported.
# @param environment Environment to be sanitized.
# @param path [optional] A search path, defaults to PATH.
# @return Returns success (status 0) or failure (status 1).
# */
__gvm_environment_sanitize() {
    local environment="${1}"; shift
    local shell_path="${1:-$PATH}"
    local active_go="$(PATH="${shell_path}" which go)"
    local active_go_root="${GOROOT}"
    local system_list; system_list=()
    local defaultIFS="${IFS}"
    local IFS="${defaultIFS}"

    # We only sanitize 'system' and 'system@'' environments
    [[ "${environment}" =~ ^system(@.*)?$ ]] || return 0

    # If env is 'system' or 'system@global', GOROOT might point to a non-existing path if user has upgraded the binary
    # since the 'system' env files were generated. We need to try and update GOROOT or warn user.

    if [[ -x "${active_go}" && ! -d "${active_go_root}" ]]
    then
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "__gvm_environment_sanitize() - Original GOROOT: ${GOROOT}"

        local old_go_root="${active_go_root}" && unset GOROOT
        local new_go_root="$(PATH="${shell_path}" go env GOROOT 2>/dev/null)"

        # set GOROOT based on currently active go
        #
        # This should not be needed for a correctly installed system go (found in standard path locations). If the user
        # has somehow placed a go binary (installed with GVM) in the PATH, then GOROOT will be empty now (the binaries
        # have set a GOROOT of /usr/local/go). Essentially, this is just here for unit testing.
        #
        if [[ -z "${new_go_root// /}" ]]
        then
            new_go_root="${active_go%/bin/go}"
        fi

        # update system and system@global environments
        IFS=$'\n' system_list=( $(\ls -1 "${GVM_ROOT}/environments/system"*) ) IFS="${defaultIFS}"

        local _env_file
        for _env_file in "${system_list[@]}"
        do
            sed -i.bak 's|'${old_go_root}'|'${new_go_root}'|g' "${_env_file}" \
            && rm "${_env_file}.bak"
        done
        unset _env_file

        # source updated environment file
        source "${GVM_ROOT}/environments/${environment}" &> /dev/null

        unset new_go_root
        unset old_go_root

        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "__gvm_environment_sanitize() - Sanitized GOROOT: ${GOROOT}"
    elif [[ ! -x "${active_go}" ]]
    then
        __gvm_display_error "Failed to find a path to Go for requested environment: '${environment}'." || return 1
    fi

    return 0
}
