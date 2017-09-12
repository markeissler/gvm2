source "${SANDBOX}/gvm2/scripts/gvm"
source "${SANDBOX}/gvm2/scripts/env/use.sh" || return 1


##
## Test output messages
##

gvm linkthis -h # status=0; match=/Usage: gvm linkthis \[option\] \[<package>\]/
gvm linkthis --help # status=0; match=/Usage: gvm linkthis \[option\] \[<package>\]/

## Setup expectation

## 1.8.2
gvm uninstall --force go1.8.2 > /dev/null 2>&1
gvm install go1.8.2 --binary

## Create a pkgset
gvm use go1.8.2
gvm pkgset create go1.8_linkthis
gvm pkgset use go1.8_linkthis

## Test linkthis without args
mkdir -p "${SANDBOX}/linkthis-test-1/mypackage"
cp "${SANDBOX}/gvm2/tests/gvm_cross_test_input_hello.go" "${SANDBOX}/linkthis-test-1"

## Execute command
result_1="$(builtin cd "${SANDBOX}/linkthis-test-1/mypackage"; __gvm_use "go1.8.2@go1.8_linkthis" > /dev/null; "${SANDBOX}/gvm2/scripts/linkthis" > /dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "0" ]] # status=0

## check that link creates at pkgset src level
[[ -L "${SANDBOX}/gvm2/pkgsets/go1.8.2/go1.8_linkthis/src/mypackage" ]] # status=0

## Test linkthis with package args
mkdir -p "${SANDBOX}/linkthis-test-2/mypackage"
cp "${SANDBOX}/gvm2/tests/gvm_cross_test_input_hello.go" "${SANDBOX}/linkthis-test-2"

## Execute command
result_2="$(builtin cd "${SANDBOX}/linkthis-test-2/mypackage"; __gvm_use "go1.8.2@go1.8_linkthis" > /dev/null; "${SANDBOX}/gvm2/scripts/linkthis" "github.com/jonytest/mypackage" > /dev/null; echo $?)"

## check that link creates at pkgset/src/github.com/jonytest/mypackage
[[ -L "${SANDBOX}/gvm2/pkgsets/go1.8.2/go1.8_linkthis/src/github.com/jonytest/mypackage" ]] # status=0
