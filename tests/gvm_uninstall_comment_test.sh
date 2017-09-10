source "${SANDBOX}/gvm2/scripts/gvm"

##
## Test output messages
##

gvm uninstall # status=1; match=/ERROR: Please specify the Go version/
gvm uninstall -h # status=0; match=/Usage: gvm uninstall \[option\] <version ...>/
gvm uninstall --help # status=0; match=/Usage: gvm uninstall \[option\] <version ...>/

## Setup expectation

## 1.8.2
gvm uninstall --force go1.8.2 > /dev/null 2>&1
gvm install go1.8.2 --binary

## Uninstall abort
yes n | gvm uninstall "go1.8.2" # status=0; match=/Action cancelled/

## Uninstall
gvm uninstall --force "go1.8.2" # status=0; match=/Go versions uninstalled successfully/

## Uninstall non-existing
gvm uninstall --force "go1.8.2" # status=1; match=/Go version specified is not installed/
