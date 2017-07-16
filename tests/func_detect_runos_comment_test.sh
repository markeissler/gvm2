g_path_script="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"
. "${g_path_script}/../scripts/function/detect_runos.sh" || return 1

##
## detect system runtime
##

## Setup expectation
platform="$(uname)"

## NOTE: Multiline constructs are not supported in tf!
[[ "$(uname)" == "Darwin" ]] && expectedRunOSRegex='^darwin,osx10.[0-9]*,amd64$'
[[ "$(uname)" == "Linux" ]] && expectedRunOSRegex='^linux,,amd64$'

## Execute command
runOS="$(__gvm_detect_runos)"

echo "expectedRunOSRegex: ${expectedRunOSRegex}"
echo "runOS: ${runOS}"

## Evaluate result

[[ "${runOS}" =~ ${expectedRunOSRegex} ]] # status=0
