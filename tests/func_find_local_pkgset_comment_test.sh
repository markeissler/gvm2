source "${SANDBOX}/gvm2/scripts/function/find_local_pkgset.sh" || return 1

##
## find a local package set
##
startDir="${SANDBOX}/gvm2/abcd12345afg"

## Setup expectation (startdir, finaldir, retval, retstatus)
mkdir -p "${startDir}_1/.gvm_local"
mkdir -p "${startDir}_2"
expect_1=( "${startDir}_1"  "${SANDBOX}/gvm2"  "${startDir}_1/.gvm_local"  "0")
expect_2=( "${startDir}_2"  "${SANDBOX}/gvm2"  ""                          "1")

##
## find a local package set (return status)
##

## Execute command
result_1="$(__gvm_find_local_pkgset "${expect_1[0]}" "${expect_1[1]}" > /dev/null; echo $?)"
result_2="$(__gvm_find_local_pkgset "${expect_2[0]}" "${expect_2[1]}" > /dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "${expect_1[3]}" ]] # status=0
[[ "${result_2}" -eq "${expect_2[3]}" ]] # status=0

##
## find a local package set (return value)
##

## Execute command
result_1="$(__gvm_find_local_pkgset "${expect_1[0]}" "${expect_1[1]}")"
result_2="$(__gvm_find_local_pkgset "${expect_2[0]}" "${expect_2[1]}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[2]}" ]] # status=0
[[ "${result_2}" == "${expect_2[2]}" ]] # status=0

##
## find a local package set (RETVAL value)
##

## Execute command
result_1="$(__gvm_find_local_pkgset "${expect_1[0]}" "${expect_1[1]}" >/dev/null; echo "${RETVAL}")"
result_2="$(__gvm_find_local_pkgset "${expect_2[0]}" "${expect_2[1]}" >/dev/null; echo "${RETVAL}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[2]}" ]] # status=0
[[ "${result_2}" == "${expect_2[2]}" ]] # status=0

## Cleanup
rmdir "${startDir}_1/.gvm_local" "${startDir}_1" "${startDir}_2"
