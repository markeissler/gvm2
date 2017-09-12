##
## Test latest beta builds.
##

##
## Build go
##

## Cleanup test objects
gvm uninstall --force go1.9beta2 > /dev/null 2>&1

## 1.9beta2
CGO_ENABLED=0 gvm install go1.9beta2 #status=0
gvm list #status=0; match=/go1.9beta2/

##
## Install binary go
##

## Cleanup test objects
gvm uninstall --force go1.9beta2 > /dev/null 2>&1

## 1.9beta2
gvm install go1.9beta2 --binary #status=0
gvm list #status=0; match=/go1.9beta2/

## Cleanup test objects
gvm uninstall --force go1.9beta2 > /dev/null 2>&1
