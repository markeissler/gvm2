g_path_script="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"
. "${g_path_script}/../scripts/function/find_available.sh" || return 1

##
## find available Go versions
##
## Depends on go1.2.2 and go1.3.3 being installed by 00gvm_install_comment_test.sh!
##

##
## find https://go.googlesource.com/go
##

## Setup expectation - nothing to do

## Execute command
availableHash=( "$(__gvm_find_available "https://go.googlesource.com/go")" )

## Evaluate result
## @TODO: tf refuses to count an array:
##  [[ ${\#availableHash[@]} -ge 2 ]] # status=0
[[ "$(valueForKeyFakeAssocArray "go1.2.2" "${availableHash[*]}")" == "https://go.googlesource.com/go" ]] # status=0
[[ "$(valueForKeyFakeAssocArray "go1.3.3" "${availableHash[*]}")" == "https://go.googlesource.com/go" ]] # status=0
[[ "$(valueForKeyFakeAssocArray "go1.0.x" "${availableHash[*]}")" == "https://go.googlesource.com/go" ]] # status=1

##
## find https://github.com/golang/go
##

## Execute command
availableHash=( "$(__gvm_find_available "https://github.com/golang/go")" )

## Evaluate result
## @TODO: tf refuses to count an array:
##  [[ ${\#availableHash[@]} -eq 1 ]] # status=0
[[ "$(valueForKeyFakeAssocArray "go1.2.2" "${availableHash[*]}")" == "https://github.com/golang/go" ]] # status=0
[[ "$(valueForKeyFakeAssocArray "go1.3.3" "${availableHash[*]}")" == "https://github.com/golang/go" ]] # status=0
[[ "$(valueForKeyFakeAssocArray "go1.0.x" "${availableHash[*]}")" == "https://github.com/golang/go" ]] # status=1
