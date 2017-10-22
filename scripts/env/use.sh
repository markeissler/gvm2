# scripts/env/use.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_ENV_USE:-} -eq 1 ]] && return || readonly GVM_ENV_USE=1

# load dependencies
dep_load()
{
    local srcd="${BASH_SOURCE[0]}"; srcd="${srcd:-${(%):-%x}}"
    local base="$(builtin cd "$(dirname "${srcd}")" && builtin pwd)"
    local deps; deps=(
        "../function/_bash_pseudo_hash.sh"
        "../function/_shell_compat.sh"
        "../function/display_notices.sh"
        "../function/environment_sanitize.sh"
        "../function/export_path.sh"
        "../function/find_installed.sh"
        "../function/locale_text.sh"
        "../function/munge_path.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load; unset -f dep_load &> /dev/null || unset dep_load

# __gvm_use()
# /*!
# @abstract Select a Go version
# @discussion
# For basic usage, this function select the version specified as a string
#   argument. The argument list is parsed...
#
# For more advanced usage the following options are supported:
# <pre>@textblock</pre>
#   Usage: gvm use [--version] <value> [--pkgset <value>] [--default]
#          gvm use <version-name>@<pkgset-name> [--default]
#
#   Options:
#     --version value       version name
#     --pkgset value        standard pkgset name
#     --default             make selected pkgset default
#     --quiet               suppress 'now using' acknowledgements
#     -h, --help            show this message
#
#   When using --pkgset, you must also specify a go version name.
# @/textblock</pre>
# @param args Variable list of options and values
# @return Returns success (status 0) if a pkgset was selected successfully or
#   (status 1) failure if an error was encountered.
# */
__gvm_use()
{
    local options_hash; options_hash=()
    local accumulator; accumulator=()

    # Go version regex patterns are specifically implemented to output rematches
    # in a consistent format. Consider the following examples:
    #	go1
    #	go1.7.1
    #	release.r60.2
    #	system
    #   master
    #   go1.7.1@my-first-pkgset
    #   release.r60.2@my-second-pkgset
    #
    # These rematches apply:
    #	GVM_REMATCH[1]: version name (e.g. go1, go1.7.1, release.r60.2, system)
    #	GVM_REMATCH[2]: isolated version (e.g. 1, 1.7.1, 60.2, ' ')
    # In addition, if a pkgset has been provided as part of the version string,
    # the following additional rematch will apply:
    #	GVM_REMATCH[5]: isolated pkgset (e.g. my-first-pkgset, etc.)
    #
    # The regex patterns are implemented separately for the above patterns so
    # that specific matches can be discarded later. Patterns are built up in
    # steps for clarity.
    #
    local goversion_regex='^(go([0-9]+(\.[0-9]+[a-z0-9]*)*))$'
    local goversion_release_regex='^(release\.r([0-9]+(\.[0-9]+[a-z0-9]*)*))$'
    local goversion_system_regex='^(system(()))$'
    local goversion_master_regex='^(master(()))$'
    # system and master could be handled by alias pattern but it separate for now
    local goversion_alias_regex='^([a-zA-Z]+(()))$'
    # append pkgset_regex to the end of each pattern
    local pkgset_regex='([A-Za-z0-9]+[A-Za-z0-9._#:%\/\+\-]+)'
    local at_pkgset_regex="(@${pkgset_regex})?"
    goversion_regex="${goversion_regex/%\$/$at_pkgset_regex}\$"
    goversion_release_regex="${goversion_release_regex/%\$/$at_pkgset_regex}\$"
    goversion_system_regex="${goversion_system_regex/%\$/$at_pkgset_regex}\$"
    goversion_master_regex="${goversion_master_regex/%\$/$at_pkgset_regex}\$"
    goversion_alias_regex="${goversion_alias_regex/%\$/$at_pkgset_regex}\$"
    local version_rematch

    for _option in "${@}"
    do
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Parsing ${FUNCNAME[0]}() argument: ${_option:-[EMPTY]}"

        # if the accumulator has a trailing option flag (that is, the option
        # flag has been specified but no argument has been supplied) then make
        # sure the next _option value is not another option flag.
        if [[ $(( ${#accumulator[@]}%2 )) -eq 1 && "${_option}" =~ ^[\-]+ ]]
        then
            echo "Missing argument for: '${accumulator[${#accumulator[@]}-1]}'"
            return 1
        fi

        # scan version_rematch checks exactly once each time through
        version_rematch=false
        if __gvm_rematch "${_option}" "${goversion_regex}" ||
           __gvm_rematch "${_option}" "${goversion_release_regex}" ||
           __gvm_rematch "${_option}" "${goversion_system_regex}" ||
           __gvm_rematch "${_option}" "${goversion_master_regex}" ||
           __gvm_rematch "${_option}" "${goversion_alias_regex}"
        then
            version_rematch=true
        fi

        # parse all freeform strings first according to regex patterns above
        if [[ "${version_rematch}" == true ]] && [[ $(( ${#accumulator[@]}%2 )) -eq 0 ]]
        then
            # if the regex matches and the accumulator is even, we can add the
            # key/val pair.
            accumulator+=( "--version" "${GVM_REMATCH[1]}" )
            # if pkgset is present, add that to the accumulator as well
            # other --pkgset argument supplied.
            if [[ -n "${GVM_REMATCH[5]}" ]]
            then
                accumulator+=( "--pkgset" "${GVM_REMATCH[5]}" )
            fi
        elif [[ "${version_rematch}" == true ]] &&
                [[ ${#accumulator[@]} -gt 0 &&
                    "${accumulator[${#accumulator[@]}-1]}" == "--version" ]]
        then
            # if the regex matches and the accumulator is odd, the previous
            # element in the accumulator must be the option for which this
            # regex matches, we then just add the value.
            accumulator+=( "${GVM_REMATCH[1]}" )
        elif __gvm_rematch "${_option}" "^${pkgset_regex}$" && [[ $(( ${#accumulator[@]}%2 )) -eq 0 ]]
        then
            accumulator+=( "--pkgset" "${GVM_REMATCH[1]}" )
        elif [[ "${_option}" =~ ^${pkgset_regex}$
            && ${#accumulator[@]} -gt 0
            && "${accumulator[${#accumulator[@]}-1]}" == "--pkgset" ]]
        then
            accumulator+=( "${GVM_REMATCH[1]}" )
        elif [[ "${_option}" == "--version" ]]
        then
            accumulator+=( "--version" )
        elif [[ "${_option}" == "--pkgset" ]]
        then
            accumulator+=( "--pkgset" )
        elif [[ "${_option}" == "--default" ]]
        then
            accumulator+=( "--default" "true" )
        elif [[ "${_option}" == "--quiet" ]]
        then
            accumulator+=( "--quiet" "true" )
        elif [[ "${_option}" == "-h" || "${_option}" == "--help" ]]
        then
            __gvm_locale_text_for_key "help/usage_use" > /dev/null
            printf "%s\n" "${RETVAL}"
            return 0
        else
            __gvm_display_warning "Unrecognized command line argument: '${_option}'"
            return 1
        fi
        # flush accumulator when we reach an even number of key/value pairs
        if [[ $(( ${#accumulator[@]}%2 )) -eq 0 ]]
        then
            for (( i=0; i<${#accumulator[@]}; i+=2 ))
            do
                local __key __val
                __key="${accumulator[i]}"
                __val="${accumulator[i+1]}"
                {
                    setValueForKeyFakeAssocArray "${__key}" "${__val}" "${options_hash[*]}" > /dev/null
                    options_hash=( ${RETVAL} )
                }
                unset __key __val
            done
            accumulator=()
        fi
    done
    unset accumulator

    if [[ "${GVM_DEBUG}" -eq 1 ]]
    then
        printf "Command (%s) options dump:\n" "${BASH_SOURCE[0]##*/}"
        local _item
        for _item in "${options_hash[@]}"
        do
            local __key="${_item%%:*}"
            local __val=""
            {
                valueForKeyFakeAssocArray "${__key}" "${options_hash[*]}" > /dev/null
                __val="${RETVAL}"
            }
            printf "  [%s]: %s\n" "${__key}" "${__val}"
            unset __key __val
        done
        unset _item
    fi

    local version=""
    {
        valueForKeyFakeAssocArray "--version" "${options_hash[*]}" > /dev/null
        version="${RETVAL}"
    }

    if [[ -z "${version// /}" ]]
    then
        __gvm_display_error "Please specify the version. Execute 'gvm use --help' for command help."
        return 1
    fi

    # check to see if requested version is already installed, if not advise user on how to
    # proceed:
    #   1. if no binaries installed and no source cache directory exists, then tell user no Gos have been installed and
    #      provide instructions on how to begin.
    #   2. if source cache directory exists, then tell user they can build requested version from local cache.
    #   3. if version exists on download server, tell user they can either build from source or install binary from a
    #      remote server.
    __gvm_find_installed "" "${GVM_ROOT}/gos" > /dev/null
    local installed_hash; installed_hash=( ${RETVAL} )
    if [[ "${GVM_DEBUG}" -eq 1 ]]
    then
        printf "Command (%s) installed versions dump:\n" "${BASH_SOURCE[0]##*/}"
        prettyDumpFakeAssocArray "${installed_hash[*]}"
    fi
    if ! valueForKeyFakeAssocArray "${version}" "${installed_hash[*]}" > /dev/null
    then
        local go_archive_path="$GVM_ROOT/archive/go"

        # no binaries installed and no source archive installed?
        if [[ ${#installed_hash[@]} -eq 0 && ! -d "${go_archive_path}" ]]
        then
            __gvm_locale_text_for_key "go_install_prompt" > /dev/null
            __gvm_display_error "${RETVAL}"
            return 1
        fi

        # source archive installed and version can be built locally
        if [[ -d "${go_archive_path}" && "$(builtin cd "${go_archive_path}" && git tag -l "${version}")" != "" ]]
        then
            __gvm_locale_text_for_key "go_install_version_local" > /dev/null
            __gvm_display_warning "${RETVAL}"
            return 1
        fi
        unset go_archive_path

        # does version exist remotely? version can be downloaded as binary or source, otherwise bail.
        local available_hash; available_hash=( "$(__gvm_find_available "https://go.googlesource.com/go")" )
        if valueForKeyFakeAssocArray "${version}" "${available_hash[*]}" > /dev/null
        then
            __gvm_locale_text_for_key "go_install_version_upstream" > /dev/null
            __gvm_display_error "${RETVAL}"
            return 1
        else
            __gvm_locale_text_for_key "go_install_version_invalid" > /dev/null
            __gvm_display_error "${RETVAL}"
            return 1
        fi
        unset available_hash
    fi
    unset installed_hash

    __gvm_export_path > /dev/null
    source "$GVM_ROOT/environments/$version" &> /dev/null || __gvm_display_error "Couldn't source environment" || return 1
    __gvm_environment_sanitize "$version" > /dev/null

    # fix PATH to correct order
    __gvm_munge_path > /dev/null
    local fixed_path="${RETVAL}"
    [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Original path: $PATH" && echo "Munged path: ${fixed_path}"
    export PATH="${fixed_path}"
    unset fixed_path

    if valueForKeyFakeAssocArray "--default" "${options_hash[*]}" > /dev/null
    then
        cp "$GVM_ROOT/environments/$version" "$GVM_ROOT/environments/default"
        [[ $? -ne 0 ]] && __gvm_display_error "Couldn't make ${version} default"
    fi

    local pkgset=""
    {
        valueForKeyFakeAssocArray "--pkgset" "${options_hash[*]}" > /dev/null
        pkgset="${RETVAL}"
    }
    if [[ -n "${pkgset}" ]]
    then
        local pkgset_args=""
        {
            valueForKeyFakeAssocArray "--pkgset" "${options_hash[*]}"
            pkgset_args="${RETVAL}"
        }
        if valueForKeyFakeAssocArray "--default" "${options_hash[*]}" > /dev/null
        then
            pkgset_args+=( "--default" )
        fi

        \gvm pkgset use --quiet "${pkgset_args[@]}" || return 1
        unset pkgset_args
    fi
    unset pkgset

    if ! valueForKeyFakeAssocArray "--quiet" "${options_hash[*]}" > /dev/null
    then
        __gvm_display_message "Now using version ${version}"
    fi

    return $?
}
