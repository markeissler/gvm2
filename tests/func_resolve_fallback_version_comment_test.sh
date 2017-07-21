. "${SANDBOX}/gvm2/scripts/function/resolve_fallback_version" || return 1

## Setup expectation
expectedVersion='^go1(.[0-9]*)*$'

## Execute command
version="$(__gvm_resolve_fallback_version)"

## Evaluate result
[[ "${version}" =~ ${expectedVersion} ]] # status=0
