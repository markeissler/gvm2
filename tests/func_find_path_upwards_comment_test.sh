source "${SANDBOX}/gvm2/scripts/function/find_path_upwards.sh" || return 1

##
## find a directory
##
targetDir="tests"
startDir="${SANDBOX}/gvm2"
expectedPath="${startDir}/${targetDir}"

## Setup expectation (target, startdir, finaldir, retval, retstatus)
expect_1=( "${targetDir}"  "${startDir}"  "${SANDBOX}/gvm2"  "${expectedPath}"  "0")
expect_2=( "abcd12345afg"  "${startDir}"  "${SANDBOX}/gvm2"  ""                 "1")

##
## find directory (return status)
##

## Execute command
result_1="$(__gvm_find_path_upwards "${expect_1[0]}" "${expect_1[1]}" "${expect_1[2]}" > /dev/null; echo $?)"
result_2="$(__gvm_find_path_upwards "${expect_2[0]}" "${expect_2[1]}" "${expect_2[2]}" > /dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "${expect_1[4]}" ]] # status=0
[[ "${result_2}" -eq "${expect_2[4]}" ]] # status=0

##
## find directory (return value)
##

## Execute command
result_1="$(__gvm_find_path_upwards "${expect_1[0]}" "${expect_1[1]}" "${expect_1[2]}")"
result_2="$(__gvm_find_path_upwards "${expect_2[0]}" "${expect_2[1]}" "${expect_2[2]}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[3]}" ]] # status=0
[[ "${result_2}" == "${expect_2[3]}" ]] # status=0

##
## find directory (RETVAL value)
##

## Execute command
result_1="$(__gvm_find_path_upwards "${expect_1[0]}" "${expect_1[1]}" "${expect_1[2]}" >/dev/null; echo "${RETVAL}")"
result_2="$(__gvm_find_path_upwards "${expect_2[0]}" "${expect_2[1]}" "${expect_2[2]}" >/dev/null; echo "${RETVAL}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[3]}" ]] # status=0
[[ "${result_2}" == "${expect_2[3]}" ]] # status=0

##
## find a file
##
targetFile="func_find_path_upwards_comment_test.sh"
startDir="${SANDBOX}/gvm2/tests"
expectedPath="${startDir}/${targetFile}"

## Setup expectation (target, startdir, finaldir, retval, retstatus)
expect_1=( "${targetFile}"  "${startDir}"  "${HOME}"  "${expectedPath}"  "0")
expect_2=( "abcd12345a.sh"  "${startDir}"  "${HOME}"  ""                 "1")

##
## find a file (return status)
##

## Execute command
result_1="$(__gvm_find_path_upwards "${expect_1[0]}" "${expect_1[1]}" "${expect_1[2]}" > /dev/null; echo $?)"
result_2="$(__gvm_find_path_upwards "${expect_2[0]}" "${expect_2[1]}" "${expect_2[2]}" > /dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "${expect_1[4]}" ]] # status=0
[[ "${result_2}" -eq "${expect_2[4]}" ]] # status=0

##
## find a file (return value)
##

## Execute command
result_1="$(__gvm_find_path_upwards "${expect_1[0]}" "${expect_1[1]}" "${expect_1[2]}")"
result_2="$(__gvm_find_path_upwards "${expect_2[0]}" "${expect_2[1]}" "${expect_2[2]}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[3]}" ]] # status=0
[[ "${result_2}" == "${expect_2[3]}" ]] # status=0

##
## find a file (RETVAL value)
##

## Execute command
result_1="$(__gvm_find_path_upwards "${expect_1[0]}" "${expect_1[1]}" "${expect_1[2]}" >/dev/null; echo "${RETVAL}")"
result_2="$(__gvm_find_path_upwards "${expect_2[0]}" "${expect_2[1]}" "${expect_2[2]}" >/dev/null; echo "${RETVAL}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[3]}" ]] # status=0
[[ "${result_2}" == "${expect_2[3]}" ]] # status=0
