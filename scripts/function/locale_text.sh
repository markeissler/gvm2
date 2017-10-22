# scripts/function/locale_text.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_LOCALE_TEXT:-} -eq 1 ]] && return || readonly GVM_LOCALE_TEXT=1

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

# __gvm_locale_text_for_key()
# /*!
# @abstract Retrieve the locale text for the specified key
# @discussion
# Retrieves the locale text for the specified key from the text files located
#   in the 'locales' directory. Files in the directory are plain text and are
#   named according to the following pattern:
# <pre>@textblock
#   [locale name]_[KEY].txt
# @/textblock</pre>
#   For example, text for the key "go_install_promopt" in US english would be
#   located in a locale file with the name:
# <pre>@textblock
#   en-US_go_install_prompt.txt
# @/textblock</pre>
#   Files are limited to 100 lines of text maximum, text beyond this point will
#   be truncated and an error status will be returned. Files that consist of
#   only blank lines will be truncated and an error status will be returned so
#   that the caller can use an alternate translation.
#
#   Organization of locales in subdirectories is supported. The key will be
#   split at the last forward slash (/) character and everything to the left of
#   the slash will be appended to the 'locales' directory path while everything
#   to the right of the slash will be used to resolve the key.
#
#   <b>NOTE:</b> Only the "en-US" locale is currently implemented througout gvm.
# @param key Key for the text to retrieve
# @param locale Local code for the text to retrieve
# @param locales_dir [optional] Path to locales directory, defaults to
#   \$GVM_ROOT/locales
# @return Returns a string containing the locale text (status 0) or an empty
#   string (status 1) on failure.
# @note Also sets global variable RETVAL to the same return value.
# */
__gvm_locale_text_for_key() {
    local key_raw="${1}"
    local locale="${2:-en-US}"
    local locales_dir="${3:-$GVM_ROOT/locales}"
    local key="${key_raw}"
    unset RETVAL

    # handle the disappearance of our underlying directory structure, which can
    # happen during an upgrade.
    if [[ ! -f "${BASH_SOURCE[0]}" ]]
    then
        RETVAL="${key_raw}" && echo "${RETVAL}" && return 1
    fi

    # fixup locales_dir if default value was used but GVM_ROOT is empty
    #
    # NOTE: This should not happen but if the install is broken we still need to
    # be able to provide localized messages.
    #
    if [[ -z "${3// /}" && "${locales_dir}" =~ ^/ ]]
    then
        local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"
        locales_dir="${base}/../../locales/"
        unset base
    fi

    # parse key_raw into subdir path and key components
    if [[ "${key_raw}" =~ / ]]
    then
        key="${key_raw##*/}"
        locales_dir="${locales_dir}/${key_raw%/*}"
    fi
    local key_path="${locales_dir}/${locale}_${key}.txt"

    [[ "x${key// /}" == "x" || ! -r "${key_path}" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    local line_count=0
    local text=""
    while IFS= read -r _line; do
        (( line_count++ ))
        [[ "${line_count}" -gt 100 ]] && break
        text+="${_line}"$'\n'
    done <<< "$(cat "${key_path}")"

    [[ -z "${line_count// /}" ]] && text=""

    RETVAL="${text%$'\n'}" # output text minus last newline

    if [[ "${line_count}" -gt 100 || -z "${RETVAL// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}
