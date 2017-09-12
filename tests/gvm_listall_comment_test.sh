source "${SANDBOX}/gvm2/scripts/gvm"

##
## Test output messages
##

gvm listall -h # status=0; match=/Usage: gvm listall \[option\]/
gvm listall --help # status=0; match=/Usage: gvm listall \[option\]/

## Setup expectation

## Test listall without args
gvm listall #status=0
