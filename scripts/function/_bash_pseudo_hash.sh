# bash_pseudo_hash.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#
# Implements "fake" associative arrays suitable for use with bash(1) versions
# that precede 4.0 (with native hash table support) and zsh(1).
#
# Author : Mark Eissler (moe@markeissler.org) https://about.me/markeissler
# Website: https://github.com/markeissler/bash-pseudo-hash
#
# The MIT License (MIT)
#
# Copyright (C) 2015-2017 Mark Eissler. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# source once and only once!
[[ ${BASH_PSEUDO_HASH:-} -eq 1 ]] && return || readonly BASH_PSEUDO_HASH=1

# zsh fixups
if [[ -n "${ZSH_VERSION// /}" ]]
then
    # add bash word split emulation for zsh
    #
    # see: http://zsh.sourceforge.net/FAQ/zshfaq03.html
    #
    setopt shwordsplit

    # force zsh to start arrays at index 0
    setopt KSH_ARRAYS
fi

# setValueForKeyFakeAssocArray()
# /*!
# @abstract Set value for key from a fake associative array
# @discussion
# Iterates over target_ary (an indexed array), searching for target_key, if the
#   key is found its value is set to new_value otherwise the target_key and
#   new_value are appended to the array.
#
#   The indexed array values must conform to this format:
#     "key:value"
#   Where key and value are separated by a single colon character.
#
#   Specify empty values as an empty, quoted string.
#
#   So-called "fake" associative arrays are useful for environments where the
#   installed version of bash(1) precedes 4.0.
# <pre>@textblock
#   hash=()
#   key1="Phrase1"
#   val1="1000 pounds of spaghetti"
#   key2="Phrase2"
#   val2="And a bottle of beer."
#   hash=( $(setValueForKeyFakeAssocArray "${key1}" "${val1}" "${hash[*]}") )
#   hash=( $(setValueForKeyFakeAssocArray "${key2}" "${val2}" "${hash[*]}") )
# @/textblock</pre>
#
#   Best practice is to use RETVAL for variable assignment:
# <pre>@textblock
#   hash=()
#   key1="Phrase1"
#   val1="1000 pounds of spaghetti"
#   key2="Phrase2"
#   val2="And a bottle of beer."
#   setValueForKeyFakeAssocArray "${key1}" "${val1}" "${hash[*]}" > /dev/null; hash=( ${RETVAL} )
#   setValueForKeyFakeAssocArray "${key2}" "${val2}" "${hash[*]}" > /dev/null; hash=( ${RETVAL} )
# @/textblock</pre>
# @param target_key Key to retrieve
# @param new_value New or updated value
# @param target_ary Indexed array to scan
# @return Returns new array with updated key (status 0) or an empty array
#   (status 1) on failure.
# @note Also sets global variable RETVAL to the same return value.
# */
setValueForKeyFakeAssocArray()
{
    # parameter list supports empty arguments!
    local target_key="${1}"; shift
    local new_value="${1//@/\\@}"; new_value="${new_value:-@@}"; shift # @todo: need to support setting nil values!
    local target_ary; target_ary=()
    local defaultIFS="$IFS"
    local IFS="$defaultIFS"
    local found=false
    unset RETVAL

    IFS=$' ' target_ary=( ${1} ) IFS="$defaultIFS"

    [[ -z "${target_key// /}" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    local _target_ary_length=${#target_ary[@]}
    local _encoded_new_value=""
    __bphp_encode "${new_value}" > /dev/null; _encoded_new_value="${RETVAL}"
    local i
    for (( i=0; i<${_target_ary_length}; i++ ))
    do
        local __val="${target_ary[i]}"

        if [[ "${__val%%:*}" == "${target_key}" ]]
        then
            target_ary[$i]="${__val%%:*}:${_encoded_new_value}"
            found=true
            break
        fi

        unset __val
    done
    unset i _target_ary_length

    # key not found, append
    [[ "${found}" == false ]] && target_ary+=( "${target_key}:${_encoded_new_value}" )

    RETVAL="${target_ary[*]}"

    echo "${RETVAL}" && return 0
}

# valueForKeyFakeAssocArray()
# /*!
# @abstract Fetch value for key from a fake associative array
# @discussion
# Iterates over target_ary (an indexed array), searching for target_key, if the
#   key is found its value is returned.
#
#   The indexed array values must conform to this format:
#     "key:value"
#   Where key and value are separated by a single colon character.
#
#   So-called "fake" associative arrays are useful for environments where the
#   installed version of bash(1) precedes 4.0.
# <pre>@textblock
#   hash=() # hash returned previously by setValueForKeyFakeAssocArray()
#   key1="Phrase1"
#   key2="Phrase2"
#   val1="$(valueForKeyFakeAssocArray "${key1}" "${hash[*]}")"
#   val2="$(valueForKeyFakeAssocArray "${key2}" "${hash[*]}")"
# @/textblock</pre>
#
#   Best practice is to use RETVAL for variable assignment:
# <pre>@textblock
#   hash=() # hash returned previously by setValueForKeyFakeAssocArray()
#   key1="Phrase1"
#   key2="Phrase2"
#   local val1="" val2=""
#   valueForKeyFakeAssocArray "${key1}" "${hash[*]}" > /dev/null; val1="${RETVAL}"
#   valueForKeyFakeAssocArray "${key1}" "${hash[*]}" > /dev/null; val2="${RETVAL}"
# @/textblock</pre>
# @param target_key Key to retrieve
# @param target_ary Indexed array to scan
# @return Returns string containing value (status 0 if non-empty, status 1 if
#   empty) or an empty string (status 2) on key not found or target_key is empty.
# @note Also sets global variable RETVAL to the same return value.
# */
valueForKeyFakeAssocArray()
{
    local target_key="${1}"; shift
    local target_ary; target_ary=()
    local defaultIFS="$IFS"
    local IFS="$defaultIFS"
    local value=""
    local found_key=false
    unset RETVAL

    IFS=$' ' target_ary=( ${1} ) IFS="$defaultIFS"

    [[ -z "${target_key// /}" || ${#target_ary[@]} -eq 0 ]] && RETVAL="" && echo "${RETVAL}" && return 2

    local _item
    for _item in "${target_ary[@]}"
    do
        if [[ "${_item%%:*}" == "${target_key}" ]]
        then
            found_key=true
            # @todo: need to support returning nil values!
            __bphp_decode "${_item#*:}" > /dev/null; value="${RETVAL}"
            # decode nils
            value="${value//@@/}"; value="${value//\\@/@}"
            break
        fi
    done
    unset _item

    if [[ "${found_key}" == false ]]
    then
        RETVAL="" && echo "${RETVAL}"
        return 2
    elif [[ -z "${value// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}"
        return 1
    fi

    echo "${RETVAL}" && return 0
}

# keysForFakeAssocArray()
# /*!
# @abstract Returns list of keys in fake associative array
# @discussion
# Iterates over target_ary (an indexed array) and extracts key component from
#   each element.
# @param target_ary Indexed array to scan
# @return Returns string of space separated keys (status 0) or an empty string
#   (status 1) on failure.
# @note Also sets global variable RETVAL to the same return value.
# */
keysForFakeAssocArray() {
    local target_ary; target_ary=()
    local target_ary_keys; target_ary_keys=()
    local defaultIFS="$IFS"
    local IFS="$defaultIFS"
    unset RETVAL

    IFS=$' ' target_ary=( ${1} ) IFS="$defaultIFS"

    [[ ${#target_ary[@]} -eq 0 ]] && RETVAL="" && echo "${RETVAL}" && return 1

    local _item
    for _item in "${target_ary[@]}"
    do
        _item="${_item}"
        target_ary_keys+=( "${_item%%:*}" )
    done
    unset _item

    if [[ "${#target_ary_keys[@]}" -eq 0 ]]
    then
        RETVAL="" && echo "${RETVAL}"
        return 1
    fi

    RETVAL="${target_ary_keys[*]}"

    echo "${RETVAL}" && return 0
}

# prettyDumpFakeAssocArray()
# /*!
# @abstract Output a pretty-printed dump of fake associative array contents
# @discussion
# Iterates over target_ary (an indexed array) and extracts keys and values from
#   each element. Pretty prints the output in the following format:
# <pre>@textblock
#   [key]: value
# /@textblock</pre>
# @param target_ary Indexed array to scan
# @return Returns formatted string of key/values (status 0) or an empty string
#   (status 1) on failure.
# */
prettyDumpFakeAssocArray() {
    local target_ary; target_ary=()
    local defaultIFS="$IFS"
    local IFS="$defaultIFS"

    IFS=$' ' target_ary=( ${1} ) IFS="$defaultIFS"

    [[ ${#target_ary[@]} -eq 0 ]] && echo "" && return 1

    local _item
    for _item in "${target_ary[@]}"
    do
        local __key="${_item%%:*}"
        local __val=""
        valueForKeyFakeAssocArray "${__key}" "${target_ary[*]}" > /dev/null; __val="${RETVAL}"
        printf "  [%s]: %s\n" "${__key}" "${__val}"
        unset __key __val
    done
    unset _item
}

# __bphp_encode()
# /*!
# @internal
# */
__bphp_encode()
{
    local string="${1}"
    local new_string=""
    local LANG=C
    unset RETVAL

    [[ -z "${string// /}" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    local _string_len=${#string}
    local i
    for (( i = 0; i<${_string_len}; i++ ))
    do
        local __char="${string:$i:1}"
        case $__char in
            [A-Za-z0-9.~_-] )
                new_string+="$__char"
                ;;
            * )
                if [[ -n "${ZSH_VERSION// /}" ]]
                then
                    if [[ -z "${ZSH_VERSION_ARY[@]}" ]]
                    then
                        __bphp_parse_semver "${ZSH_VERSION}" > /dev/null
                        ZSH_VERSION_ARY=( ${RETVAL} )
                    fi
                    if [[ ${ZSH_VERSION_ARY[0]} -gt 5 ]] || [[ ${ZSH_VERSION_ARY[0]} -eq 5 && ${ZSH_VERSION_ARY[1]} -ge 3 ]]
                    then
                        printf -v __char '\\x%02X' "'$__char"
                    else
                        __char="$(printf '\\x%02X' "'$__char")"
                    fi
                else
                    printf -v __char '\\x%02X' "'$__char"
                fi
                new_string+="${__char//\\x/%}"
                ;;
        esac
    done
    unset i _string_len

    if [[ -z "${new_string// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}"
        return 1
    fi

    RETVAL="${new_string}"

    echo "${RETVAL}" && return 0
}

# __bphp_decode()
# /*!
# @internal
# */
__bphp_decode()
{
    local string="${1}"
    local new_string
    unset RETVAL

    [[ -z "${string// /}" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    if [[ -n "${ZSH_VERSION// /}" ]]
    then
        if [[ -z "${ZSH_VERSION_ARY[@]}" ]]
        then
            __bphp_parse_semver "${ZSH_VERSION}" > /dev/null
            ZSH_VERSION_ARY=( ${RETVAL} )
        fi
        if [[ ${ZSH_VERSION_ARY[0]} -gt 5 ]] || [[ ${ZSH_VERSION_ARY[0]} -eq 5 && ${ZSH_VERSION_ARY[1]} -ge 3 ]]
        then
            printf -v new_string "%b" "${string//\%/\\x}"
        else
            new_string="$(printf "%b" "${string//\%/\\x}")"
        fi
    else
        printf -v new_string "%b" "${string//\%/\\x}"
    fi

    if [[ -z "${new_string// /}" ]]
    then
        RETVAL="" && echo "${RETVAL}"
        return 1
    fi

    RETVAL="${new_string}"

    echo "${RETVAL}" && return 0
}

__bphp_parse_semver()
{
    local string="${1}"
    local semver_ary; semver_ary=()
    unset RETVAL

    [[ -z "${string// /}" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    local major="${string%%.*}"; major="${major:-0}"
    local minor="${string%.*}"; minor="${minor#*.}"; minor="${minor:-0}"
    local patch="${string##*.}"; patch="${patch:-0}"

    semver_ary=( "${major}" "${minor}" "${patch}" )

    if [[ ${#semver_ary[@]} -eq 0 ]]
    then
        RETVAL=""; echo "${RETVAL}"; return 1
    fi

    RETVAL="${semver_ary[*]}"; echo "${RETVAL}"; return 0
}

__bph_version()
{
    local version="1.4.1"

    echo "${version}" && return 0
}
