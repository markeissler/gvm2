source "${SANDBOX}/gvm2/scripts/function/semver_tools.sh" || return 1

##
## compare SemVer versions (return status)
##

## Setup expectation (left, right, retval, retstatus)
expect_1=( "0.9.2" "0.10.2"  "2"  "2" )
expect_2=( "1.2"   "0.9.2"   "1"  "1" )
expect_3=( "1.2.0"  "1.2.0"  "0"  "0" )
expect_4=( "1.2"    "1.2.0"  "0"  "0" )
expect_5=( "1.2.0"  "1.2"    "0"  "0" )
expect_6=( "1.0.1"  "1.0.1"  "0"  "0" )
expect_7=( "1.2.0"  "1.0.1"  "1"  "1" )
expect_8=( "1.1.0"  "1.2.1"  "2"  "2" )

##
## compare SemVer versions (return status)
##

## Execute command
result_1="$(__gvm_compare_versions "${expect_1[0]}" "${expect_1[1]}" >/dev/null; echo $?)"
result_2="$(__gvm_compare_versions "${expect_2[0]}" "${expect_2[1]}" >/dev/null; echo $?)"
result_3="$(__gvm_compare_versions "${expect_3[0]}" "${expect_3[1]}" >/dev/null; echo $?)"
result_4="$(__gvm_compare_versions "${expect_4[0]}" "${expect_4[1]}" >/dev/null; echo $?)"
result_5="$(__gvm_compare_versions "${expect_5[0]}" "${expect_5[1]}" >/dev/null; echo $?)"
result_6="$(__gvm_compare_versions "${expect_6[0]}" "${expect_6[1]}" >/dev/null; echo $?)"
result_7="$(__gvm_compare_versions "${expect_7[0]}" "${expect_7[1]}" >/dev/null; echo $?)"
result_8="$(__gvm_compare_versions "${expect_8[0]}" "${expect_8[1]}" >/dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "${expect_1[3]}" ]] # status=0
[[ "${result_2}" -eq "${expect_2[3]}" ]] # status=0
[[ "${result_3}" -eq "${expect_3[3]}" ]] # status=0
[[ "${result_4}" -eq "${expect_4[3]}" ]] # status=0
[[ "${result_5}" -eq "${expect_5[3]}" ]] # status=0
[[ "${result_6}" -eq "${expect_6[3]}" ]] # status=0
[[ "${result_7}" -eq "${expect_7[3]}" ]] # status=0
[[ "${result_8}" -eq "${expect_8[3]}" ]] # status=0

##
## compare SemVer versions (return value)
##

## Execute command
result_1="$(__gvm_compare_versions "${expect_1[0]}" "${expect_1[1]}")"
result_2="$(__gvm_compare_versions "${expect_2[0]}" "${expect_2[1]}")"
result_3="$(__gvm_compare_versions "${expect_3[0]}" "${expect_3[1]}")"
result_4="$(__gvm_compare_versions "${expect_4[0]}" "${expect_4[1]}")"
result_5="$(__gvm_compare_versions "${expect_5[0]}" "${expect_5[1]}")"
result_6="$(__gvm_compare_versions "${expect_6[0]}" "${expect_6[1]}")"
result_7="$(__gvm_compare_versions "${expect_7[0]}" "${expect_7[1]}")"
result_8="$(__gvm_compare_versions "${expect_8[0]}" "${expect_8[1]}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[2]}" ]] # status=0
[[ "${result_2}" == "${expect_2[2]}" ]] # status=0
[[ "${result_3}" == "${expect_3[2]}" ]] # status=0
[[ "${result_4}" == "${expect_4[2]}" ]] # status=0
[[ "${result_5}" == "${expect_5[2]}" ]] # status=0
[[ "${result_6}" == "${expect_6[2]}" ]] # status=0
[[ "${result_7}" == "${expect_7[2]}" ]] # status=0
[[ "${result_8}" == "${expect_8[2]}" ]] # status=0

##
## compare SemVer versions (RETVAL value)
##

## Execute command
result_1="$(__gvm_compare_versions "${expect_1[0]}" "${expect_1[1]}" >/dev/null; echo "${RETVAL}")"
result_2="$(__gvm_compare_versions "${expect_2[0]}" "${expect_2[1]}" >/dev/null; echo "${RETVAL}")"
result_3="$(__gvm_compare_versions "${expect_3[0]}" "${expect_3[1]}" >/dev/null; echo "${RETVAL}")"
result_4="$(__gvm_compare_versions "${expect_4[0]}" "${expect_4[1]}" >/dev/null; echo "${RETVAL}")"
result_5="$(__gvm_compare_versions "${expect_5[0]}" "${expect_5[1]}" >/dev/null; echo "${RETVAL}")"
result_6="$(__gvm_compare_versions "${expect_6[0]}" "${expect_6[1]}" >/dev/null; echo "${RETVAL}")"
result_7="$(__gvm_compare_versions "${expect_7[0]}" "${expect_7[1]}" >/dev/null; echo "${RETVAL}")"
result_8="$(__gvm_compare_versions "${expect_8[0]}" "${expect_8[1]}" >/dev/null; echo "${RETVAL}")"

## Evaluate result
[[ "${result_1}" == "${expect_1[2]}" ]] # status=0
[[ "${result_2}" == "${expect_2[2]}" ]] # status=0
[[ "${result_3}" == "${expect_3[2]}" ]] # status=0
[[ "${result_4}" == "${expect_4[2]}" ]] # status=0
[[ "${result_5}" == "${expect_5[2]}" ]] # status=0
[[ "${result_6}" == "${expect_6[2]}" ]] # status=0
[[ "${result_7}" == "${expect_7[2]}" ]] # status=0
[[ "${result_8}" == "${expect_8[2]}" ]] # status=0
