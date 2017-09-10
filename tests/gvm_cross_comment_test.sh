source "${SANDBOX}/gvm2/scripts/gvm"
source "${SANDBOX}/gvm2/scripts/env/use.sh" || return 1

##
## Test output messages
##

gvm cross # status=1; match=/ERROR: Please specify the cross compilation platform operating system/
gvm cross -h # status=0; match=/Usage: gvm cross \[option\] <os> <arch> \[sub-option\] <file ...>/
gvm cross --help # status=0; match=/Usage: gvm cross \[option\] <os> <arch> \[sub-option\] <file ...>/
gvm cross -l # status=0; match=/Go cross compile platforms/
gvm cross --list # status=0; match=/Go cross compile platforms/
gvm cross --list --porcelain # status=0; match!=/Go cross compile platforms/

## Setup expectation

## 1.8.2
gvm uninstall --force go1.8.2 > /dev/null 2>&1
gvm install go1.8.2 --binary

## Test a cross compile of hello.go
mkdir -p "${SANDBOX}/cross-test"
cp "${SANDBOX}/gvm2/tests/gvm_cross_test_input_hello.go" "${SANDBOX}/cross-test"

## Execute command
result_1="$(builtin cd "${SANDBOX}/cross-test"; __gvm_use "go1.8.2" > /dev/null; "${SANDBOX}/gvm2/scripts/cross" "linux" "386" "gvm_cross_test_input_hello.go" > /dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "0" ]] # status=0
