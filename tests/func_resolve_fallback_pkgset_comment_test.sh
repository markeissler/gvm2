. "${SANDBOX}/gvm2/scripts/function/resolve_fallback_pkgset.sh" || return 1

##
## resolve fallback pkgset
##

## Setup expectation (go_version, retval, retstatus)
expect_1=( "$gvm_go_name"  "global"  "0" )
expect_2=( "abcd12345afg"  ""        "1" )
##expectedPkgset="global"

##
## resolve fallback pkgset (return status)
##

## Execute command
result_1="$(__gvm_resolve_fallback_pkgset "${expect_1[0]}" > /dev/null; echo $?)"
result_2="$(__gvm_resolve_fallback_pkgset "${expect_2[0]}" > /dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "${expect_1[2]}" ]] # status=0
[[ "${result_2}" -eq "${expect_2[2]}" ]] # status=0

##
## resolve fallback pkgset (return value)
##

## Execute command
result_1="$(__gvm_resolve_fallback_pkgset "${expect_1[0]}")"
result_2="$(__gvm_resolve_fallback_pkgset "${expect_2[0]}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[1]}" ]] # status=0
[[ "${result_2}" == "${expect_2[1]}" ]] # status=0

##
## resolve fallback pkgset (RETVAL value)
##

## Execute command
result_1="$(__gvm_resolve_fallback_pkgset "${expect_1[0]}" > /dev/null; echo "${RETVAL}")"
result_2="$(__gvm_resolve_fallback_pkgset "${expect_2[0]}" > /dev/null; echo "${RETVAL}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[1]}" ]] # status=0
[[ "${result_2}" == "${expect_2[1]}" ]] # status=0
