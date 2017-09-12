source "${SANDBOX}/gvm2/scripts/gvm"
source "${SANDBOX}/gvm2/scripts/env/use.sh" || return 1
source "${SANDBOX}/gvm2/scripts/env/pkgset_use.sh" || return 1

##
## Test output messages
##

gvm pkgset # status=1; match=/Unrecognized command: empty/
gvm pkgset -h # status=0; match=/Usage: gvm pkgset <command> \[option\]/
gvm pkgset --help # status=0; match=/Usage: gvm pkgset <command> \[option\]/
gvm pkgset create # status=1; match=/ERROR: Please specify the package set \(pkgset\) name/
gvm pkgset create -h # status=0; match=/Usage: gvm pkgset create \[option\] <pkgset>/
gvm pkgset create --help # status=0; match=/Usage: gvm pkgset create \[option\] <pkgset>/
gvm pkgset delete # status=1; match=/ERROR: Please specify the package set \(pkgset\) name/
gvm pkgset delete --help # status=0; match=/Usage: gvm pkgset delete \[option\] <pkgset>/
gvm pkgset empty # status=1; match=/ERROR: Please specify the package set \(pkgset\) name/
gvm pkgset empty -h # status=0; match=/Usage: gvm pkgset empty \[option\] <pkgset>/
gvm pkgset empty --help # status=0; match=/Usage: gvm pkgset empty \[option\] <pkgset>/

## Setup expectation

## 1.8.2
gvm uninstall --force go1.8.2 > /dev/null 2>&1
gvm install go1.8.2 --binary
gvm use go1.8.2

## Create a pkgset
gvm pkgset create "test-pkg" # status=0; match=/Package set \(pkgset\) created successfully/
[[ -d "${SANDBOX}/gvm2/pkgsets/go1.8.2/test-pkg" ]] # status=0

## List pkgsets
gvm pkgset list # status=0; match=/test-pkg/

## Empty a pkgset
gvm pkgset empty "test-pkg" # status=0; match=/Package set \(pkgset\) flushed \(emptied\) successfully/

## Delete a pkgset
gvm pkgset delete "test-pkg" # status=0; match=/Package set \(pkgset\) deleted successfully/
[[ ! -d "${SANDBOX}/gvm2/pkgsets/go1.8.2/test-pkg" ]] # status=0

##
## Local pkgset
##
mkdir -p "${SANDBOX}/pkgset-test-1/myproject"

## Execute command (pkgset-create --local)
result_1="$(builtin cd "${SANDBOX}/pkgset-test-1/myproject"; __gvm_use "go1.8.2" > /dev/null; "${SANDBOX}/gvm2/scripts/pkgset-create" "--local" > /dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "0" ]] # status=0
[[ -d "${SANDBOX}/pkgset-test-1/myproject/.gvm_local/pkgsets/go1.8.2/local" ]] # status=0

## Execute command (pkgset-list)
result_1="$(builtin cd "${SANDBOX}/pkgset-test-1/myproject"; __gvm_use "go1.8.2" > /dev/null; "${SANDBOX}/gvm2/scripts/pkgset-list")"

## Evaluate result
[[ "${result_1}" =~ "L ${SANDBOX}/pkgset-test-1/myproject" ]] # status=0

## Execute command (pkgset-empty --local)
result_1="$(builtin cd "${SANDBOX}/pkgset-test-1/myproject"; __gvm_use "go1.8.2" > /dev/null; __gvm_pkgset_use --local > /dev/null; "${SANDBOX}/gvm2/scripts/pkgset-empty" "--local" > /dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "0" ]] # status=0

## Execute command (pkgset-delete --local)
result_1="$(builtin cd "${SANDBOX}/pkgset-test-1/myproject"; __gvm_use "go1.8.2" > /dev/null; __gvm_pkgset_use --local > /dev/null; "${SANDBOX}/gvm2/scripts/pkgset-delete" "--local" > /dev/null; echo $?)"

## Evaluate result
[[ "${result_1}" -eq "0" ]] # status=0
[[ ! -d "${SANDBOX}/pkgset-test-1/myproject/.gvm_local/pkgsets/go1.8.2/local" ]] # status=0
