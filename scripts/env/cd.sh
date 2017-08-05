#!/usr/bin/env bash
# cd
#
# shellcheck shell=bash
# vi: set ft=bash
#
# Override the cd() function to implement auto-switching of go version and
# pkgset when changing into a directory.
#

# load dependencies
dep_load()
{
    local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"
    local deps; deps=(
        "../functions"
        "../function/_bash_pseudo_hash.sh"
        "../function/_shell_compat.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load; unset -f dep_load

# user could be reloading this file, restore preserved functions if we've been
# through here already.
if __gvm_is_function __gvm_oldcd
then
    # output from declare -f on zsh omits a newline before opening brace, so
    # we need to add the newline for consistency with bash.
    eval "$(echo "cd()"; declare -f __gvm_oldcd | sed '1 s/{/\'$'\n''{/' | tail -n +2)"
    unset -f __gvm_oldcd
fi

if __gvm_is_function cd
then
    eval "$(echo "__gvm_oldcd()"; declare -f cd | sed '1 s/{/\'$'\n''{/' | tail -n +2)"
elif [[ "$(builtin type cd)" == "cd is a shell builtin" ]]
then
    eval "$(echo "__gvm_oldcd() { builtin cd \$*; return \$?; }")"
fi

# Path cleanup
#
# Sort all paths, place rvm paths first, followed by gvm, followed by the rest.
# We do this so that rvm and gvm can live together happily.
#
# NOTE: Cleanup will also take place everytime 'gvm use' or 'gvm pkgset use' is
# executed but we do it now just to call it from some place on login.
#
__gvm_munge_path > /dev/null
[[ $? -ne 0 ]] && __gvm_display_warning "Unable to cleanup PATH. Leaving it alone." && return 1
export PATH="${RETVAL}"

# cd()
# /*!
# @abstract Override the cd() function to implement auto-switching of go version
#   and pkgset when changing into a directory
# @discussion
# This override seeks to preserve the functionality of any pre-existing override
#  of the cd() function.
# @param path Path of directory to change into
# @return Returns success (status 0) or failure (status 1).
# */
cd() {
    unset RETVAL

    # @FIXME: gvm_oldcd is broken on re-sourcing .bashrc!
    if __gvm_is_function __gvm_oldcd
    then
        __gvm_oldcd $*
    fi

    local dot_go_version dot_go_pkgset rslt
    local defaults_go_name defaults_go_pkgset
    local defaults_resolved=false
    local defaults_hash; defaults_hash=()

    if [[ "$GVM_ROOT" == "" ]]; then
        __gvm_display_error "GVM_ROOT not set. Please source \$GVM_ROOT/scripts/gvm"
        return $?
    fi

    # gather default environment settings, they can change at any time!
    [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Resolving defaults..."

    __gvm_read_environment_file "${GVM_ROOT}/environments/default" > /dev/null; rslt=$?
    defaults_hash=( ${RETVAL} )

    if [[ $rslt -eq 0 ]]
    then
        defaults_resolved=true
    else
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Can't find default environment. Falling back to system."

        __gvm_read_environment_file "${GVM_ROOT}/environments/system" > /dev/null; rslt=$?
        defaults_hash=( ${RETVAL} )

        if [[ $rslt -eq 0 ]]
        then
            defaults_resolved=true
        else
            [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Can't find system environment."
        fi
    fi

    if [[ "${defaults_resolved}" == false ]]
    then
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Resolving fallback go version and pkgset from all available."

        local fallback_go_version=""
        __gvm_resolve_fallback_version > /dev/null
        fallback_go_version="${RETVAL}"

        local fallback_go_pkgset=""
        __gvm_resolve_fallback_pkgset "${fallback_go_version}" > /dev/null
        fallback_go_pkgset="${RETVAL}"

        defaults_hash=( $(setValueForKeyFakeAssocArray "gvm_go_name" "${fallback_go_version}" "${defaults_hash[*]}") )
        defaults_hash=( $(setValueForKeyFakeAssocArray "gvm_pkgset_name" "${fallback_go_pkgset}" "${defaults_hash[*]}") )

        unset fallback_go_version
        unset fallback_go_pkgset

        defaults_resolved=true
    fi

    defaults_go_name="$(valueForKeyFakeAssocArray "gvm_go_name" "${defaults_hash[*]}")"
    defaults_go_pkgset="$(valueForKeyFakeAssocArray "gvm_pkgset_name" "${defaults_hash[*]}")"
    if [[ "${GVM_DEBUG}" -eq 1 ]]
    then
        echo "Resolved default go: ${defaults_go_name:-[EMPTY]}"
        echo "Resolved default pkgset: ${defaults_go_pkgset:-[EMPTY]}"
    fi

    __gvmp_find_closest_dot_go_version > /dev/null; rslt=$?
    dot_go_version="${RETVAL}"

    if [[ $rslt -eq 0 ]]
    then
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Found dot_go_version: ${dot_go_version}"

        local use_goversion=""
        __gvmp_read_dot_go_version "${dot_go_version}" > /dev/null
        use_goversion="${RETVAL}"

        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Switching to: ${use_goversion}"

        \gvm use --quiet "${use_goversion}" || return 1

        unset use_goversion
    elif [[ -n "${defaults_go_name}" ]]
    then
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "No .go-version found. Using system or default go."
        \gvm use --quiet "${defaults_go_name}" || return 1
    else
        # quietly failing
        if [[ "${GVM_DEBUG}" -eq 1 ]]
        then
            local installed_hash; installed_hash=()
            __gvm_find_installed "" "${GVM_ROOT}/gos" > /dev/null
            installed_hash=( ${RETVAL} )

            local go_archive_path="$GVM_ROOT/archive/go"

            echo "No fallback go version could be found."

            # no binaries installed and no source archive installed?
            if [[ ${#installed_hash[@]} -eq 0 && ! -d "${go_archive_path}" ]]
            then
                __gvm_locale_text_for_key "go_install_prompt" > /dev/null
                __gvm_display_error "${RETVAL}"
                return 1
            fi

            unset go_archive_path
            unset installed_hash
        fi

        # not a cd() error, just a gvm error...need to pretend nothing happened!
        return 0
    fi

    __gvmp_find_closest_dot_go_pkgset > /dev/null; rslt=$?
    dot_go_pkgset="${RETVAL}"

    if [[ $rslt -eq 0 ]]
    then
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Found .go-pkgset: ${dot_go_pkgset}"

        local use_gopkgset=""
        __gvmp_read_dot_go_pkgset "${dot_go_pkgset}" > /dev/null
        use_gopkgset="${RETVAL}"

        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Switching to: ${use_gopkgset}"

        \gvm pkgset use --quiet "${use_gopkgset}" || return 1
        unset use_gopkgset
    elif [[ -n "${defaults_go_pkgset}" ]]
    then
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "No .go-pkgset found. Using system or default pkgset."
        \gvm pkgset use --quiet "${defaults_go_pkgset}" || return 1
    else
        # quietly failing
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "No fallback pkgset could be found."
    fi

    return 0
}

function __gvmp_find_closest_dot_go_version() {
    unset RETVAL

    __gvm_find_path_upwards ".go-version" > /dev/null

    if [[ -z "${RETVAL// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}

function __gvmp_find_closest_dot_go_pkgset() {
    unset RETVAL

    __gvm_find_path_upwards ".go-pkgset" > /dev/null

    if [[ -z "${RETVAL// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}

function __gvmp_read_dot_go_version() {
    local filepath="${1}"
    local version=""
    local regex='^(go([0-9]+(\.[0-9]+)*))$'
    unset RETVAL

    while IFS=$'\n' read -r _line; do
        # skip comment lines
        [[ "${_line}" =~ \#.* ]] && continue

        # looking for pattern "go1.2[.3]"
        if [[ "${_line}" =~ ${regex} ]]
        then
            version="${_line}"
            break
        fi
    done <<< "$(cat "${filepath}")"

    RETVAL="${version}"

    if [[ -z "${RETVAL// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}

function __gvmp_read_dot_go_pkgset() {
    local filepath="${1}"
    local pkgset=""
    local regex='^([A-Za-z0-9._#:%\+\-]+)$'
    unset RETVAL

    while IFS=$'\n' read -r _line; do
        # skip comment lines
        [[ "${_line}" =~ \#.* ]] && continue

        # fairly loose naming convention, exclude @ symbol
        if [[ "${_line}" =~ ${regex} ]]
        then
            pkgset="${_line}"
            break
        fi
    done <<< "$(cat "${filepath}")"

    RETVAL="${pkgset}"

    if [[ -z "${RETVAL// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}
