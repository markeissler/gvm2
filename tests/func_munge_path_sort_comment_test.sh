. "${SANDBOX}/gvm2/scripts/function/munge_path" || return 1

##
## munge a path
##

## Setup expectation
expectedMungedPath="/Users/me/.rvm/gems/ruby-2.3.0/bin"
expectedMungedPath+=":/Users/me/.rvm/gems/ruby-2.3.0@global/bin"
expectedMungedPath+=":/Users/me/.rvm/rubies/ruby-2.3.0/bin"
expectedMungedPath+=":/Users/me/.rvm/bin"
expectedMungedPath+=":/Users/me/.gvm/pkgsets/system/global/bin"
expectedMungedPath+=":/Users/me/.gvm/bin"
expectedMungedPath+=":/usr/local/Cellar/go/1.8.3/libexec/bin"
expectedMungedPath+=":/usr/local/heroku/bin"
expectedMungedPath+=":~/bin"
expectedMungedPath+=":/usr/local/bin"
expectedMungedPath+=":/usr/local/sbin"
expectedMungedPath+=":/Applications/Postgres.app/Contents/Versions/latest/bin"
expectedMungedPath+=":/Applications/Xcode.app/Contents/Developer/usr/bin"
expectedMungedPath+=":/usr/local/opt/maven/libexec/bin"
expectedMungedPath+=":/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home/bin"
expectedMungedPath+=":/usr/local/share/npm/bin"
expectedMungedPath+=":/usr/local/bin"
expectedMungedPath+=":/usr/bin"
expectedMungedPath+=":/bin"
expectedMungedPath+=":/usr/sbin"
expectedMungedPath+=":/sbin"
expectedMungedPath+=":/usr/local/share/dotnet"
expectedMungedPath+=":/Library/Frameworks/Mono.framework/Versions/Current/Commands"
expectedMungedPath+=":/usr/texbin"

## Execute command
testPath="/Users/me/.gvm/pkgsets/system/global/bin"
testPath+=":/Users/me/.gvm/bin"
testPath+=":/usr/local/Cellar/go/1.8.3/libexec/bin"
testPath+=":/Users/me/.rvm/gems/ruby-2.3.0/bin"
testPath+=":/Users/me/.rvm/gems/ruby-2.3.0@global/bin"
testPath+=":/Users/me/.rvm/rubies/ruby-2.3.0/bin"
testPath+=":/usr/local/heroku/bin"
testPath+=":~/bin"
testPath+=":/usr/local/bin"
testPath+=":/usr/local/sbin"
testPath+=":/Applications/Postgres.app/Contents/Versions/latest/bin"
testPath+=":/Applications/Xcode.app/Contents/Developer/usr/bin"
testPath+=":/usr/local/opt/maven/libexec/bin"
testPath+=":/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home/bin"
testPath+=":/usr/local/share/npm/bin"
testPath+=":/Users/me/.rvm/bin"
testPath+=":/usr/local/bin"
testPath+=":/usr/bin"
testPath+=":/bin"
testPath+=":/usr/sbin"
testPath+=":/sbin"
testPath+=":/usr/local/share/dotnet"
testPath+=":/Library/Frameworks/Mono.framework/Versions/Current/Commands"
testPath+=":/usr/texbin"

mungedPath="$(__gvm_munge_path "${testPath}" false)"

echo "testPath: ${testPath}"
echo "expectedMungedPath: ${expectedMungedPath}"
echo "mungedPath: ${mungedPath}"

## Evaluate result
[[ "${mungedPath}" == "${expectedMungedPath}" ]] # status=0
