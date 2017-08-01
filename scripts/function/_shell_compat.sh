# shell_compat.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#
# Shell compatiblity glue functions.
#

# source once and only once!
[[ ${GVM_SHELL_COMPAT:-} -eq 1 ]] && return || readonly GVM_SHELL_COMPAT=1

# force zsh to start arrays at index 0
[[ -n $ZSH_VERSION ]] && setopt KSH_ARRAYS

# __gvm_is_function()
# /*!
# @abstract Returns whether or not a named function exists in the shell.
# @param func_name Name of the function to check
# @return Returns success (status 0) if the named function exists or failure
#   (status 1).
# */
__gvm_is_function()
{
    local func_name="${1}"

    [[ "x${func_name}" == "x" ]] && return 1

    # using 'declare -f' is the most reliable way for both bash and zsh!
    builtin declare -f "${1}" >/dev/null

    return $?
}

__gvm_callstack()
{
    local index=${1}

    if [[ "x${BASH_VERSION}" != "x" ]]
    then
        echo "${FUNCNAME[index]}"
    elif [[ "x${ZSH_VERSION}" != "x" ]]
    then
        echo "${FUNCNAME[index+1]}"
    else
        echo "unknown caller"
        return 1
    fi

    return 0
}

# __gvm_rematch()
# /*!
# @abstract Provide a cross-platform regex rematcher.
# @discussion
# This function implements consistent regex rematch functionality for bash and
#   zsh shells. The result is similar to the output expected using the '=~'
#   pattern match operator in bash: matching results will be written to an array
#   stored in the var_name provided or 'GVM_REMATCH' (the default).
#
# Rematch results can be accessed beginning with index 1: GVM_REMATCH[1] and
#   subsequent matches (if any) appear in later indexes. The match at index 1
#   consists of the entire matched string while later matches are related to
#   specified capture groups noted in the regex pattern.
# @param string The string to match against the regex pattern
# @param regex The regex pattern
# @param var_name [optional] The name of the variable into which the resulting
#   rematch array will be set.
# @return Returns success (status 0) if the string matches the regex pattern,
#   otherwise failure (status 1).
# */
__gvm_rematch()
{
    local string="${1}"; shift
    local regex="${1}"; shift
    local var_name="${1:-GVM_REMATCH}"
    local rematch_ary; rematch_ary=()

    [[ ${#string} -eq 0 ]] && return 1
    [[ ${#regex} -eq 0 ]] && return 1

    # perform regex - same on bash and ksh
    [[ "${string}" =~ $regex ]]
    [[ $? -ne 0 ]] && return 1

    # support bash and zsh
    #
    # NOTE: 'setopt KSH_ARRAYS' must be set for zsh to force array indexes to
    # start at 0, like bash.
    #
    if [[ "x${BASH_VERSION}" != "x" ]]
    then
        rematch_ary+=( "${BASH_REMATCH[@]}" )
    elif [[ "x${ZSH_VERSION}" != "x" ]]
    then
        rematch_ary+=( "$MATCH" "${match[@]}" )
    else
        return 1
    fi

    if [[ "${var_name}" != "$" ]]
    then
        # assign to passed var
        eval "${var_name}=( \"\${rematch_ary[@]}\" )"
    fi

    return 0
}

# __gvm_setenv()
# /*!
# @abstract Set an environment variable
# @discussion
# Variable names are uppercased before they are set. Setting an empty value will
#   remove the environment variable.
# @param variable Name of the variable to set
# @param value Value of the variable
# @return Returns success (status 0) or failure (status 1).
# */
__gvm_setenv()
{
    local name="${1}"; shift
    local value="${1}"

    if [[ "x${BASH_VERSION}" != "x" ]]
    then
        if [[ "${BASH_VERSION:0:1}" -gt 3 ]]
        then
            name="${name^^}"
        else
            name="$(tr '[:lower:]' '[:upper:]' <<< "$name")"
        fi
    elif [[ "x${ZSH_VERSION}" != "x" ]]
    then
        name="${name:u}"
    else
        return 1
    fi

    [[ ${#name} -eq 0 ]] && return 1

    if [[ ${#value} -eq 0 ]]
    then
        unset "${name}"
        # verify var removed or return error
        [[ "x${name}" != "x" ]] && return 1
        # success!
        return 0
    fi

    export "${name}=${value}"

    # value not set?
    [[ "x${name}" == "x" || "${name}" != "${value}" ]] && return 1

    return 0
}
