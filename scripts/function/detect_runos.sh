# detect_runos
#

# source once and only once!
[[ ${GVM_DETECT_RUNOS:-} -eq 1 ]] && return || readonly GVM_DETECT_RUNOS=1

# load dependencies
dep_load() {
    local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"
    local deps; deps=(
        "_shell_compat.sh"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load

# __gvm_detect_runos()
# /*!
# @abstract Detect operating system we are running on
# @discussion
# Determines characteristics of the running operating system including:
#   * operating system (Darwin/macOS, Linux)
#   * operation system version (osx10.8)
#   * hardware architecture (amd64, 386)
#
# Results are returned as a string containing a comma separated list of values
#   in the following format:
# <pre>@textblock
#   os,os_version,arch
#
#   Example:
#       darwin,osx10.8,amd64
#       linux,,386
# @/textblock</pre>
#   Only Darwin/macOS and Linux platforms are currently supported. The operating
#   system version is only reported for Darwin/macOS at this time.
# @return Returns a string containing a detected configuration (status 0) or an
#   an empty string (status 1) on failure.
# */
__gvm_detect_runos()
{
    # return cached value from env if it exists
    [[ "x${GVM_RUNOS}" != "x" ]] && echo "${GVM_RUNOS}" && return 0

	local _run_os="unknown,"
	local _uname_str="$(uname)"
	local _uname_arc="$(uname -m)"

	if [ "${_uname_str}" == "Darwin" ]
    then
		local _macos_version
		_run_os="darwin"
		_macos_version="$(sw_vers -productVersion | cut -d "." -f 2)"
		if [ "${_macos_version}" -ge 8 ]
        then
			_run_os="${_run_os},osx10.8"
		elif [ "${_macos_version}" -ge 6 ]
        then
			_run_os="${_run_os},osx10.6"
		else
			display_error "Binary Go unavailable for this platform"
			rm -rf $GO_INSTALL_ROOT
			rm -f $GO_BINARY_PATH
			exit 1
		fi
		unset _macos_version
	elif [ "${_uname_str}" == "Linux" ]
    then
		_run_os="linux,"
	fi

	if [ "${_uname_arc}" == "x86_64" ]
    then
		_run_os="${_run_os},amd64"
	else
		_run_os="${_run_os},386"
	fi

    __gvm_setenv "GVM_RUNOS" "${_run_os}"

	echo "${_run_os}"

	unset _uname_arc
    unset _uname_str
    unset _run_os
}
