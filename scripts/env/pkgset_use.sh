# scripts/env/pkgset_use.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_ENV_PKGSET_USE:-} -eq 1 ]] && return || readonly GVM_ENV_PKGSET_USE=1

# load dependencies
dep_load()
{
    local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"
    local deps; deps=(
        "../function/_bash_pseudo_hash.sh"
        "../function/_shell_compat.sh"
        "../function/display_notices.sh"
        "../function/export_path.sh"
        "../function/find_local_pkgset.sh"
        "../function/locale_text.sh"
        "../function/munge_path.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load; unset -f dep_load

# __gvm_pkgset_use()
# /*!
# @abstract Select a gvm pkgset
# @discussion
# For basic usage, this function selects the pkgset specified as a string
#   argument. The argument list is parsed and both standard pkgset and local
#   pkgset names are identified by pattern (where the latter pattern begins
#   with a forward slash and generally conforms with a file path pattern).
#
#   For more advanced usage the following options are supported:
# <pre>@textblock
#   Usage: gvm pkgset use [--pkgset ] <value> [--default]
#          gvm pkgset use --local [<value>]
#
#   Options:
#     --pkgset value        standard pkgset name
#     --local value         local pkgset name (follows file path pattern)
#     --default             make selected pkgset default
#     --quiet               suppress 'now using' acknowledgements
#     -h, --help            show this message
#
#   The --pkgset and --local options are exclusive (only one can be specified).
# @/textblock</pre>
#   The default option is only supported for standard pkgsets. If both standard
#   and local pkgsets are supplied as arguments, the local pkgset will be
#   selected and the standard pkgset argument will be ignored.
# @param args Variable list of options and values
# @return Returns success (status 0) if a pkgset was selected successfully or
#   (status 1) failure if an error was encountered.
# */
__gvm_pkgset_use()
{
    local options_hash; options_hash=()
    local accumulator; accumulator=()

    # gvm pkgset regex patterns are specifically implement to output rematches
    # in a consistent format. Consider the following examples:
    #   my-pkgset
    #   my-pkgset.12.3
    #   /home/me/dev/project (a local pkgset)
    #
    # These rematches apply:
    #   GVM_REMATCH[1]: pkgset name (e.g. my-pkgset, /home/me/dev/project)
    #
    local pkgset_regex='^([A-Za-z0-9]+[A-Za-z0-9._#:%\/\+\-]+)$'
    local local_pkgset_regex='^(\/[^:\\\n\\\0]*)+$'
    local pkgset_rematch local_pkgset_rematch

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

        # scan pkgset_rematch checks exactly once each time through
        pkgset_rematch=false
        if __gvm_rematch "${_option}" "${pkgset_regex}"
        then
            pkgset_rematch=true
        fi

        # scan local_pkgset_rematch checks exactly once each time through
        local_pkgset_rematch=false
        if __gvm_rematch "${_option}" "${local_pkgset_regex}"
        then
            local_pkgset_rematch=true
        fi

        # parse all freeform strings first according to regex patterns above
        if [[ "${pkgset_rematch}" == true ]] && [[ $(( ${#accumulator[@]}%2 )) -eq 0 ]]
        then
            # if the regex matches and the accumulator is even, we can add the
            # key/val pair.
            accumulator+=( "--pkgset" "${GVM_REMATCH[1]}" )
        elif [[ "${pkgset_rematch}" == true ]] &&
            [[ ${#accumulator[@]} -gt 0 &&
                "${accumulator[${#accumulator[@]}-1]}" == "--pkgset" ]]
        then
            # if the regex matches and the accumulator is odd, the previous
            # element in the accumulator must be the option for which this
            # regex matches, we then just add the value.
            accumulator+=( "${GVM_REMATCH[1]}" )
        elif [[ "${local_pkgset_rematch}" == true ]] && $(( ${#accumulator[@]}%2 )) -eq 0 ]]
        then
            accumulator+=( "--local" "${GVM_REMATCH[1]}")
        elif [[ "${local_pkgset_rematch}" == true ]] &&
            valueForKeyFakeAssocArray "--local" "${options_hash[*]}" > /dev/null
        then
            # --local is a special case: for legacy compatibility we need to
            # support the option without an argument (we do that later by always
            # setting a value of nil). But here we are checking if the option
            # has been set previously and then just adding an override if true.
            accumulator+=( "--local" "${GVM_REMATCH[1]}" )
        elif [[ "${_option}" == "--local" ]]
        then
            accumulator+=( "--local" "nil" )
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
            __gvm_locale_text_for_key "help/usage_pkgset_use" > /dev/null
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

    if [[ "${GVM_DEBUG}" -eq 1 && ${#accumulator[@]} -gt 0 ]]
    then
        printf "Accumulator wasn't flushed. Remaining elements:\n"
        local _item _index=0
        for _item in "${accumulator[@]}"
        do
            printf "  [%s]: %s\n" "${_index}" "${_item}"
            unset __val
            (( index++ ))
        done
        unset _item _index
    fi
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

    [[ -n "$gvm_go_name" ]] || __gvm_display_error "No Go version selected" || return 1

    if valueForKeyFakeAssocArray "--local" "${options_hash[*]}" > /dev/null
    then
        local local_pkgset=""
        {
            valueForKeyFakeAssocArray "--local" "${options_hash[*]}" > /dev/null
            local_pkgset="${RETVAL}"
        }

        if [[ -z "${local_pkgset// /}" || "${local_pkgset}" == "nil" ]]
        then
            __gvm_find_local_pkgset > /dev/null
            local_pkgset="${RETVAL}"
        fi

        [[ -d "${local_pkgset}" ]] ||
            __gvm_display_error "Cannot find local package set" || return 1

        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Resolved local directory: ${local_pkgset}"

        fuzzy_match=$(\ls -1 "$local_pkgset/environments" | \sort | \grep "$gvm_go_name@" | \grep "local" | \head -n 1)
        [[ -n "${fuzzy_match}" ]] || __gvm_display_error "Cannot find local package set" || return 1

        if valueForKeyFakeAssocArray "--default" "${options_hash[*]}" > /dev/null
        then
            __gvm_display_error "Cannot set local pkgset as default"
            return 1
        fi

        __gvm_export_path > /dev/null
        source "$local_pkgset/environments/$fuzzy_match" ||
            __gvm_display_error "Failed to source the package set environment" || return 1

        # fix PATH to correct order
        __gvm_munge_path > /dev/null
        local fixed_path="${RETVAL}"
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Original path: $PATH" && echo "Munged path: ${fixed_path}"
        export PATH="${fixed_path}"
        unset fixed_path

        if ! valueForKeyFakeAssocArray "--quiet" "${options_hash[*]}" > /dev/null
        then
            echo "Now using version $gvm_go_name in local package set"
            echo "Local GOPATH is now $local_pkgset"
        fi

        unset local_pkgset
    elif valueForKeyFakeAssocArray "--pkgset" "${options_hash[*]}" > /dev/null
    then
        local pkgset=""
        {
            valueForKeyFakeAssocArray "--pkgset" "${options_hash[*]}" > /dev/null
            pkgset="${RETVAL}"
        }

        fuzzy_match=$(\ls -1 "$GVM_ROOT/environments" | \sort | \grep "$gvm_go_name@" | \grep "${pkgset}" | \head -n 1)
        [[ -n "${fuzzy_match}" ]] || __gvm_display_error "Invalid package set: ${pkgset}" || return 1

        __gvm_export_path > /dev/null
        source "$GVM_ROOT/environments/$fuzzy_match" ||
            __gvm_display_error "Failed to source the package set environment" || return 1

        # fix PATH to correct order
        __gvm_munge_path > /dev/null
        local fixed_path="${RETVAL}"
        [[ "${GVM_DEBUG}" -eq 1 ]] && echo "Original path: $PATH" && echo "Munged path: ${fixed_path}"
        export PATH="${fixed_path}"
        unset fixed_path

        if valueForKeyFakeAssocArray "--default" "${options_hash[*]}" > /dev/null
        then
            cp "$GVM_ROOT/environments/$fuzzy_match" "$GVM_ROOT/environments/default"
            [[ $? -ne 0 ]] && __gvm_display_error "Couldn't make $fuzzy_match default"
        fi

        if ! valueForKeyFakeAssocArray "--quiet" "${options_hash[*]}" > /dev/null
        then
            echo "Now using version $fuzzy_match"
        fi

        unset pkgset
    else
        __gvm_display_error "Please specify a package set. Execute 'gvm pkgset use' --help for command help."
        return 1
    fi

    return $?
}
