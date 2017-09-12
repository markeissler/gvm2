source "${SANDBOX}/gvm2/scripts/function/resolve_fallback_version.sh" || return 1

##
## resolve fallback version
##

## Setup expectation (retval, retstatus)
expectedVersion='^go1(.[0-9]*)*$'

##
## resolve fallback version (return status)
##

## Execute command
version="$(__gvm_resolve_fallback_version > /dev/null)"

## Evaluate result
[[ "${version}" -eq "0" ]] # status=0

##
## resolve fallback version (return value)
##

## Execute command
version="$(__gvm_resolve_fallback_version)"

## Evaluate result
[[ "${version}" =~ ${expectedVersion} ]] # status=0

##
## resolve fallback version (RETVAL value)
##

## Execute command
version="$(__gvm_resolve_fallback_version > /dev/null; echo "${RETVAL}")"

## Evaluate result
[[ "${version}" =~ ${expectedVersion} ]] # status=0
