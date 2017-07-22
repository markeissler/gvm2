. "${SANDBOX}/gvm2/scripts/function/find_path_upwards" || return 1

##
## find a directory
##

## Setup expectation
expectedPathDir="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"

## Execute command
## - Determine basename (baseDir) to use as input dynamically since we don't
##   know where we are installed!
baseDir=( $(basename $expectedPathDir) )
pathDir=( $(__gvm_find_path_upwards "$baseDir") )

## Evaluate result
[[ "${pathDir}" == "${expectedPathDir}" ]] # status=0

##
## find a file
##

## Setup expectation
expectedPathFile="${SANDBOX}/gvm2/tests/func_find_path_upwards_comment_test.sh"

## Execute command
baseFile=( $(basename $expectedPathFile) )
pathFile=( $(__gvm_find_path_upwards "$baseFile") )

## Evaluate result
[[ "${pathFile}" == "${expectedPathFile}" ]] # status=0
