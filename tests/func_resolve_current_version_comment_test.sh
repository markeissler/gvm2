source "${SANDBOX}/gvm2/scripts/function/resolve_current_version.sh" || return 1
source "${SANDBOX}/gvm2/scripts/env/use.sh"

##
## resolve current version
##

## Setup expectation (version, retval, retstatus)
expect_1=( "go1.3.3"    "go1.3.3"     "0" )
expect_2=( "go1.8.2"    "go1.8.2"     "0" )

##
## resolve current version (return status)
##

## Execute command
result_1="$(__gvm_use "${expect_1[0]}" > /dev/null; __gvm_resolve_current_version >/dev/null; echo $?)"
result_2="$(__gvm_use "${expect_2[0]}" > /dev/null; __gvm_resolve_current_version >/dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "${expect_1[2]}" ]] # status=0
[[ "${result_2}" -eq "${expect_2[2]}" ]] # status=0

##
## resolve current version (return value)
##

## Execute command
result_1="$(__gvm_use "${expect_1[0]}" > /dev/null; __gvm_resolve_current_version)"
result_2="$(__gvm_use "${expect_2[0]}" > /dev/null; __gvm_resolve_current_version)"


## Evaluate result
[[ "${result_1}" == "${expect_1[1]}" ]] # status=0
[[ "${result_2}" == "${expect_2[1]}" ]] # status=0

##
## resolve current version (RETVAL value)
##

## Execute command
result_1="$(__gvm_use "${expect_1[0]}" > /dev/null; __gvm_resolve_current_version >/dev/null; echo "${RETVAL}")"
result_2="$(__gvm_use "${expect_2[0]}" > /dev/null; __gvm_resolve_current_version >/dev/null; echo "${RETVAL}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[1]}" ]] # status=0
[[ "${result_2}" == "${expect_2[1]}" ]] # status=0
