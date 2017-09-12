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
