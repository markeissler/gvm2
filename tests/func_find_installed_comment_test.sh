. "${SANDBOX}/gvm2/scripts/function/find_installed.sh" || return 1

##
## find installed Go versions
##
## Depends on go1.2.2 and go1.3.3 being installed by 00gvm_install_comment_test.sh!
##

##
## find list
##

## Setup expectation - nothing to do

## Execute command
installedHash=( "$(__gvm_find_installed "" "${SANDBOX}/gvm2/gos")" )

## Evaluate result
## @TODO: tf refuses to count an array:
##  [[ ${\#installedHash[@]} -ge 2 ]] # status=0
[[ "$(valueForKeyFakeAssocArray "go1.2.2" "${installedHash[*]}")" == "${SANDBOX}/gvm2/gos/go1.2.2" ]] # status=0
[[ "$(valueForKeyFakeAssocArray "go1.3.3" "${installedHash[*]}")" == "${SANDBOX}/gvm2/gos/go1.3.3" ]] # status=0

##
## find target
##

## Execute command
installedHash=( "$(__gvm_find_installed "go1.2.2" "${SANDBOX}/gvm2/gos")" )

## Evaluate result
## @TODO: tf refuses to count an array:
##  [[ ${\#installedHash[@]} -eq 1 ]] # status=0
[[ "$(valueForKeyFakeAssocArray "go1.2.2" "${installedHash[*]}")" == "${SANDBOX}/gvm2/gos/go1.2.2" ]] # status=0
