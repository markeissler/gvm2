# scripts/env/implode.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_IMPLODE:-} -eq 1 ]] && return || readonly GVM_IMPLODE=1

# load dependencies
dep_load()
{
    local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"
    local deps; deps=(
        "../function/_shell_compat.sh"
        "../function/display_notices.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load; unset -f dep_load

# __gvm_implode()
# /*!
# @abstract Uninstall GVM2
# @discussion
# This function is destructive and will fully uninstall the GVM2 installation
#   including all installed version of Go (those that are managed by GVM2) along
#   with all pkgset configurations.
#
# The following options are supported:
# <pre>@textblock</pre>
#   usage: gvm implode [options]
#
#   OPTIONS:
#     -f, --force                 Uninstall GVM2 without prompting for confirmation
#     -q, --quiet                 Suppress progress messages
#     -h, --help                  Show this message
# @/textblock</pre>
# @return Returns success (status 0) if operation was completed successfully or
#   failure (status 1) if an error was encountered.
# */
__gvm_implode()
{
    local opt_force=false
    local opt_quiet=false

    while true
    do
        case "${1}" in
            "")
                ;;
            -f | --force)
                opt_force=true
                ;;
            -q | --quiet)
                opt_quiet=true
                ;;
            -h | ? | help | --help )
                __gvm_locale_text_for_key "help/usage_implode" > /dev/null
                printf "%s\n" "${RETVAL}"
                return 0
                ;;
            *)
                __gvm_locale_text_for_key "unrecognized_option" > /dev/null
                printf "%s: %s\n\n" "${RETVAL}" "${1:-empty}"
                __gvm_locale_text_for_key "help/usage_implode" > /dev/null
                printf "%s\n" "${RETVAL}"
                return 1
                ;;
        esac
        # guard against accidents...
        shift; [[ "$#" -eq 0 ]] && break
    done

    if [[ "${opt_force}" == false ]]
    then
        __gvm_prompt_confirm > /dev/null
        if [[ $? -ne 0 ]]
        then
            if [[ "${opt_quiet}" == false ]]
            then
                __gvm_locale_text_for_key "action_cancelled" > /dev/null
                __gvm_display_message "${RETVAL}"
            fi
            return 0
        fi
    fi

    #
    # collect some messages ahead of time as locales are about to be deleted!
    #
    __gvm_locale_text_for_key "implode_failed" > /dev/null
    local implode_failed_msg="${RETVAL}"

    __gvm_locale_text_for_key "implode_succeeded" > /dev/null
    local implode_success_msg="${RETVAL}"

    # do it!
    rm -rf "${GVM_ROOT}"

    if [[ $? -ne 0 ]]
    then
        if [[ "${opt_quiet}" == false ]]
        then
            __gvm_display_error "${implode_failed_msg}"
        fi

        return 1
    fi

    __gvm_display_message "${implode_success_msg}"

    return 0
}
