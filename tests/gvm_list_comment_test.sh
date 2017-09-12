source "${SANDBOX}/gvm2/scripts/gvm"

##
## Test output messages
##

gvm list -h # status=0; match=/Usage: gvm list \[option\]/
gvm list --help # status=0; match=/Usage: gvm list \[option\]/

## Setup expectation

## Test list without args
gvm list # status=0

## Test active indicator
gvm use go1.3.3
gvm list # status=0; match=/=> go1.3.3/
