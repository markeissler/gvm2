# scripts/function/semver_tools.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#
# Functions for manipulating SemVer format strings.
#

# source once and only once!
[[ ${GVM_SEMVER_TOOLS:-} -eq 1 ]] && return || readonly GVM_SEMVER_TOOLS=1

# __gvm_compare_versions()
# /*!
# @abstract Compare two SemVer version strings.
# @discussion
# Compares two SemVer strings for equality. SemVer strings have the following
#   basic format:
# <pre>@textblock
#   M.m.b
#   M - Major revision
#   m - minor revision
#   b - bug revision
# @/textblock</pre>
# This function will return the following values as a return status:
#   0 - versions are equal
#   1 - version_A is greater than version_B
#   2 - version_A is less than version_B
# @param version_A Version string to compare on left
# @param version_B Version string to compare on right
# @return Returns comparison value between 0 and 2.
# @note Also sets global variable RETVAL to the same exit value.
# */
__gvm_compare_versions()
{
    local version_A="${1}"
    local version_B="${2}"
    local version_A_ary; version_A_ary=()
    local version_B_ary; version_B_ary=()
    local defaultIFS="$IFS"
    local IFS="$defaultIFS"
    unset RETVAL

	[[ "${version_A}" == "${version_B}" ]] && RETVAL=0 && return 0

    # convert version strings into arrays of elements (Major, Minor, bug)
	IFS=.
    version_A_ary=( ${1} )
    version_B_ary=( ${2} )
    IFS="$defaultIFS"

	# fill empty fields in version_A_ary with zeros
    local _i
	for (( _i=${#version_A_ary[@]}; _i<${#version_B_ary[@]}; _i++ ))
    do
		version_A_ary[_i]=0
	done
    unset _i

    local _i
	for (( _i=0; _i<${#version_A_ary[@]}; _i++ ))
    do
        if [[ -z "${version_B_ary[_i]}" ]]
        then
            # fill empty fields in version_B_ary with zeros
            version_B_ary[_i]=0
        fi
        if (( 10#${version_A_ary[_i]} > 10#${version_B_ary[_i]} ))
        then
            RETVAL=1
            return 1
        fi
        if (( 10#${version_A_ary[_i]} < 10#${version_B_ary[_i]} ))
        then
            RETVAL=2
            return 2
        fi
	done
    unset _i

	RETVAL=0 && return 0
}

# __gvm_extract_version()
# /*!
# @abstract Strip extraneous SemVer string information.
# @discussion
# Removes extra SemVer information from a Go version string including the
#   following substrings:
# <pre>@textblock
#   + beta
#   + rc
# @/textblock</pre>
# Old pre-release versions will be return an error  to a SemVer value of 0.0.1 as they are
#   irrelevant at this point. These versions include tags that begin with:
# <pre>@textblock
#   + release
#   + weekly
# @/textblock</pre>
# @param version Go version string to strip
# @return Returns string containing stripped value on success (status 0) or an
#   empty string on failure (status 1).
# @note  Also sets global variable RETVAL to the return string.
# */
__gvm_extract_version()
{
    local version="${1}"
    unset RETVAL

    [[ "x${version}" == "x" ]] && RETVAL="" && echo "${RETVAL}" && return 1

    # weekly* and release* tags are really really old pre-release versions, we
    # will just return an error for these.
    [[ "${version}" =~ release* || "${version}" =~ weekly* ]] && RETVAL="" && echo "${RETVAL}" && return 1

    RETVAL="$(echo "${version}" | sed 's/^go\(.*\)/\1/g; s/beta.*//g; s/rc.*//g')"

    echo "${RETVAL}" && return 0
}
