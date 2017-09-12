source "${SANDBOX}/gvm2/scripts/gvm"

##
## Test output messages
##

gvm diff -h # status=0; match=/Usage: gvm diff \[option\] \[<version>\]/
gvm diff --help # status=0; match=/Usage: gvm diff \[option\] \[<version>\]/

## Setup expectation

## 1.8.2
gvm uninstall --force go1.8.2 > /dev/null 2>&1
gvm install go1.8.2 --binary

## Test without any changes
gvm diff go1.8.2 # status=0; match=/Clean/

## Test with changes
touch "${SANDBOX}/gvm2/gos/go1.8.2/abcd12345afg.test"
gvm diff go1.8.2 # status=1; match=/\*Dirty\*/
