source "${SANDBOX}/gvm2/scripts/function/semver_tools.sh" || return 1

##
## strip extraneous SemVer strings from a Go version string
##

## Setup expectation (left, right, retval)
expectedVersion_1=( "go1.2.1"           "1.2.1"  "0" )
expectedVersion_2=( "go1.3beta1"        "1.3"    "0" )
expectedVersion_3=( "go1.6rc1"          "1.6"    "0" )
expectedVersion_4=( "release.r57.1"     ""       "1" )
expectedVersion_5=( "weekly.2011-12-01" ""       "1" )

##
## extract SemVer string (return status)
##

## Execute command
extractedStatus_1="$(__gvm_extract_version "${expectedVersion_1[0]}" >/dev/null; echo $?)"
extractedStatus_2="$(__gvm_extract_version "${expectedVersion_2[0]}" >/dev/null; echo $?)"
extractedStatus_3="$(__gvm_extract_version "${expectedVersion_3[0]}" >/dev/null; echo $?)"
extractedStatus_4="$(__gvm_extract_version "${expectedVersion_4[0]}" >/dev/null; echo $?)"
extractedStatus_5="$(__gvm_extract_version "${expectedVersion_5[0]}" >/dev/null; echo $?)"

## Evaluate result
[[ "${extractedStatus_1}" -eq "${expectedVersion_2[2]}" ]] # status=0
[[ "${extractedStatus_2}" -eq "${expectedVersion_2[2]}" ]] # status=0
[[ "${extractedStatus_3}" -eq "${expectedVersion_3[2]}" ]] # status=0
[[ "${extractedStatus_4}" -eq "${expectedVersion_4[2]}" ]] # status=0
[[ "${extractedStatus_5}" -eq "${expectedVersion_5[2]}" ]] # status=0

##
## extract SemVer string (return value)
##

## Execute command
extractedStatus_1="$(__gvm_extract_version "${expectedVersion_1[0]}")"
extractedStatus_2="$(__gvm_extract_version "${expectedVersion_2[0]}")"
extractedStatus_3="$(__gvm_extract_version "${expectedVersion_3[0]}")"
extractedStatus_4="$(__gvm_extract_version "${expectedVersion_4[0]}")"
extractedStatus_5="$(__gvm_extract_version "${expectedVersion_5[0]}")"

## Evaluate result

[[ "${extractedStatus_1}" == "${expectedVersion_1[1]}" ]] # status=0
[[ "${extractedStatus_2}" == "${expectedVersion_2[1]}" ]] # status=0
[[ "${extractedStatus_3}" == "${expectedVersion_3[1]}" ]] # status=0
[[ "${extractedStatus_4}" == "${expectedVersion_4[1]}" ]] # status=0
[[ "${extractedStatus_5}" == "${expectedVersion_5[1]}" ]] # status=0

##
## extract SemVer string (RETVAL value)
##

## Execute command
extractedStatus_1="$(__gvm_extract_version "${expectedVersion_1[0]}" >/dev/null; echo "${RETVAL}")"
extractedStatus_2="$(__gvm_extract_version "${expectedVersion_2[0]}" >/dev/null; echo "${RETVAL}")"
extractedStatus_3="$(__gvm_extract_version "${expectedVersion_3[0]}" >/dev/null; echo "${RETVAL}")"
extractedStatus_4="$(__gvm_extract_version "${expectedVersion_4[0]}" >/dev/null; echo "${RETVAL}")"
extractedStatus_5="$(__gvm_extract_version "${expectedVersion_5[0]}" >/dev/null; echo "${RETVAL}")"

## Evaluate result
[[ "${extractedStatus_1}" == "${expectedVersion_1[1]}" ]] # status=0
[[ "${extractedStatus_2}" == "${expectedVersion_2[1]}" ]] # status=0
[[ "${extractedStatus_3}" == "${expectedVersion_3[1]}" ]] # status=0
[[ "${extractedStatus_4}" == "${expectedVersion_4[1]}" ]] # status=0
[[ "${extractedStatus_5}" == "${expectedVersion_5[1]}" ]] # status=0
