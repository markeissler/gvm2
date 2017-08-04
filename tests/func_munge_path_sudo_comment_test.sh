source "${SANDBOX}/gvm2/scripts/function/munge_path.sh" || return 1

##
## munge a path
##

## Setup expectation
expectedMungedPath="/usr/local/rvm/gems/ruby-2.3.3/bin"
expectedMungedPath+=":/usr/local/rvm/gems/ruby-2.3.3@global/bin"
expectedMungedPath+=":/usr/local/rvm/rubies/ruby-2.3.3/bin"
expectedMungedPath+=":/usr/local/rvm/bin"
expectedMungedPath+=":/home/me/.gvm/pkgsets/system/global/bin"
expectedMungedPath+=":/home/me/.gvm/bin"
expectedMungedPath+=":/usr/lib/go/bin"
expectedMungedPath+=":/usr/local/bin"
expectedMungedPath+=":/usr/bin"
expectedMungedPath+=":/bin"
expectedMungedPath+=":/usr/local/games"
expectedMungedPath+=":/usr/games"

## Execute command
testPath="/home/me/.gvm/pkgsets/system/global/bin"
testPath+=":/home/me/.gvm/bin"
testPath+=":/usr/lib/go/bin"
testPath+=":/usr/local/rvm/gems/ruby-2.3.3/bin"
testPath+=":/usr/local/rvm/gems/ruby-2.3.3@global/bin"
testPath+=":/usr/local/rvm/rubies/ruby-2.3.3/bin"
testPath+=":/usr/local/bin"
testPath+=":/usr/bin"
testPath+=":/bin"
testPath+=":/usr/local/games"
testPath+=":/usr/games"
testPath+=":/usr/local/rvm/bin"

mungedPath="$(__gvm_munge_path "${testPath}" false)"

echo "testPath: ${testPath}"
echo "expectedMungedPath: ${expectedMungedPath}"
echo "mungedPath: ${mungedPath}"

## Evaluate result
[[ "${mungedPath}" == "${expectedMungedPath}" ]] # status=0
