source "${SANDBOX}/gvm2/scripts/gvm"

##
## Test output messages
##

gvm pkgenv -h # status=0; match=/Usage: gvm pkgenv \[option\] \[<pkgset>\]/
gvm pkgenv --help # status=0; match=/Usage: gvm pkgenv \[option\] \[<pkgset>\]/

## Setup expectation

## Test pkgenv --output without additional args
gvm pkgenv --stdout # status=0

## Test pkgenv --output with args
gvm pkgenv --stdout --version go1.3.3 # status=0
gvm pkgenv --stdout --version go1.3.3 --pkgset global # status=0
gvm pkgenv --stdout go1.3.3@global # status=0

##
## check output for active go version and pkgset
##

## 1.8.1

gvm uninstall --force go1.8.1 > /dev/null 2>&1
gvm install go1.8.1 --binary
gvm use go1.8.1

## Execute command
result_1="$(gvm use go1.8.1 > /dev/null; gvm pkgenv --resolve)"

## Evaluate result
[[ "${result_1}" =~ "GVM2 package set resolved environment" ]] # status=0
[[ "${result_1}" =~ "GVM_GO_NAME: go1.8.1" ]] # status=0
[[ "${result_1}" =~ "GVM_PKGSET_NAME: global" ]] # status=0
[[ "${result_1}" =~ "GOROOT: ${SANDBOX}/gvm2/gos/go1.8.1" ]] # status=0
[[ "${result_1}" =~ "GOPATH: ${SANDBOX}/gvm2/pkgsets/go1.8.1/global" ]] # status=0

##
## check output for specific go version and pkgset
##

## 1.7.1

gvm uninstall --force go1.7.1 > /dev/null 2>&1
gvm install go1.7.1 --binary
gvm use go1.7.1

## Execute command
result_1="$(gvm pkgenv --resolve go1.7.1@global)"

## Evaluate result
[[ "${result_1}" =~ "GVM2 package set resolved environment" ]] # status=0
[[ "${result_1}" =~ "GVM_GO_NAME: go1.7.1" ]] # status=0
[[ "${result_1}" =~ "GVM_PKGSET_NAME: global" ]] # status=0
[[ "${result_1}" =~ "GOROOT: ${SANDBOX}/gvm2/gos/go1.7.1" ]] # status=0
[[ "${result_1}" =~ "GOPATH: ${SANDBOX}/gvm2/pkgsets/go1.7.1/global" ]] # status=0
