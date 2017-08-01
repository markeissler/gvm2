. "${SANDBOX}/gvm2/scripts/function/compare_versions.sh" || return 1

##
## compare SemVer versions (return status)
##

## Setup expectation (left, right, retval)
expectedVersion_1=( "0.9.2" "0.10.2" "2" )
expectedVersion_2=( "1.2"   "0.9.2"  "1" )
expectedVersion_3=( "1.2"   "1.2.0"  "0" )
expectedVersion_4=( "1.2.0" "1.2"    "0" )

## Execute command
comparedStatus_1="$(__gvm_compare_versions "${expectedVersion_1[0]}" "${expectedVersion_1[1]}"; echo $?)"
comparedStatus_2="$(__gvm_compare_versions "${expectedVersion_2[0]}" "${expectedVersion_2[1]}"; echo $?)"
comparedStatus_3="$(__gvm_compare_versions "${expectedVersion_3[0]}" "${expectedVersion_3[1]}"; echo $?)"
comparedStatus_4="$(__gvm_compare_versions "${expectedVersion_4[0]}" "${expectedVersion_4[1]}"; echo $?)"

## Evaluate result
[[ comparedStatus_1 -eq ${expectedVersion_1[2]} ]] # status=0
[[ comparedStatus_2 -eq ${expectedVersion_2[2]} ]] # status=0
[[ comparedStatus_3 -eq ${expectedVersion_3[2]} ]] # status=0

##
## compare SemVer versions (RETVAL value)
##

## Execute command
comparedStatus_1="$(__gvm_compare_versions "${expectedVersion_1[0]}" "${expectedVersion_1[1]}"; echo $RETVAL)"
comparedStatus_2="$(__gvm_compare_versions "${expectedVersion_2[0]}" "${expectedVersion_2[1]}"; echo $RETVAL)"
comparedStatus_3="$(__gvm_compare_versions "${expectedVersion_3[0]}" "${expectedVersion_3[1]}"; echo $RETVAL)"
comparedStatus_4="$(__gvm_compare_versions "${expectedVersion_4[0]}" "${expectedVersion_4[1]}"; echo $RETVAL)"

## Evaluate result
[[ comparedStatus_1 -eq ${expectedVersion_1[2]} ]] # status=0
[[ comparedStatus_2 -eq ${expectedVersion_2[2]} ]] # status=0
[[ comparedStatus_3 -eq ${expectedVersion_3[2]} ]] # status=0
[[ comparedStatus_4 -eq ${expectedVersion_4[2]} ]] # status=0
