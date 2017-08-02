. "${SANDBOX}/gvm2/scripts/function/read_environment_file.sh" || return 1

##
## read an environment file
##

## Setup expectation
expectedHashStr="GVM_ROOT:%2fUsers%2fme%2f.gvm gvm_go_name:go1.7.1 gvm_pkgset_name:global GOROOT:%24GVM_ROOT%2fgos%2fgo1.7.1"

##
## read an environment file (return status)
##

## Execute command
result="$(__gvm_read_environment_file "${SANDBOX}/gvm2/tests/func_read_environment_file_comment_test_input.sh" > /dev/null; echo $?)"

## Evaluate result
[[ "${result[@]}" -eq "0" ]] # status=0

##
## read an environment file (return value)
##

## Execute command
result=( $(__gvm_read_environment_file "${SANDBOX}/gvm2/tests/func_read_environment_file_comment_test_input.sh") )

## Evaluate result
[[ "${result[@]}" == "${expectedHashStr}" ]] # status=0

##
## read an environment file (RETVAL value)
##

## Execute command
result=( $(__gvm_read_environment_file "${SANDBOX}/gvm2/tests/func_read_environment_file_comment_test_input.sh" > /dev/null; echo "${RETVAL}") )

## Evaluate result
[[ "${result[@]}" == "${expectedHashStr}" ]] # status=0
