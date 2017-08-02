# scripts/function/locale_text.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_LOCALE_TEXT:-} -eq 1 ]] && return || readonly GVM_LOCALE_TEXT=1

# __gvm_locale_text_for_key()
# /*!
# @abstract Retrieve the locale text for the specified key
# @discussion
# Retrieves the locale text for the specified key from the text files located
#  in the 'locales' directory. Files in the directory are plain text and are
#  named according to the following pattern:
# <pre>@textblock
#   [locale name]_[KEY].txt
# @/textblock</pre>
# For example, text for the key "go_install_promopt" in US english would be
# located in a locale file with the name:
# <pre>@textblock
#   en-US_go_install_prompt.txt
# @/textblock</pre>
# Files are limited to 10 lines of text maximum, text beyond this point will be
# truncated and an error status will be returned. Files that consist of only
# blank lines will be truncated and an error status will be returned so that the
# caller can use an alternate translation.
# <b>NOTE:</b> Only the "en-US" locale is currently implemented througout gvm.
# @param key Key for the text to retrieve
# @param locale Local code for the text to retrieve
# @param locales_dir [optional] Path to locales directory, defaults to
#   \$GVM_ROOT/locales
# @return Returns a string containing the locale text (status 0) or an empty
#   string (status 1) on failure.
# @note Also sets global variable RETVAL to the same return value.
# */
__gvm_locale_text_for_key() {
    local key="${1}"
    local locale="${2:-en-US}"
    local locales_dir="${3:-$GVM_ROOT/locales}"
    local key_path="${locales_dir}/${locale}_${key}.txt"
    unset RETVAL

    [[ "x${key// /}" == "x" || ! -r "${key_path}" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    local line_count=0
    local text=""
    while IFS= read -r _line; do
        (( line_count++ ))
        [[ "${line_count}" -gt 10 ]] && break
        text+="${_line}"$'\n'
    done <<< "$(cat "${key_path}")"

    [[ -z "${line_count// /}" ]] && text=""

    RETVAL="${text}"

    if [[ "${line_count}" -gt 10 || -z "${RETVAL// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}" && return 1
    fi

    echo "${RETVAL}" && return 0
}
