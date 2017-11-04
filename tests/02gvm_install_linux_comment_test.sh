##
## linux with gcc >= 6 should be able to build certain old versions of Go.
##

##
## Build go
##

## Cleanup test objects
gvm uninstall --force go1.7.1 > /dev/null 2>&1
gvm uninstall --force go1.8.1 > /dev/null 2>&1

## 1.7.1
CGO_ENABLED=0 gvm install go1.7.1 #status=0
gvm list #status=0; match=/go1.7.1/

## 1.8.1
CGO_ENABLED=0 gvm install go1.8.1 #status=0
gvm list #status=0; match=/go1.8.1/

## Cleanup test objects
gvm uninstall --force go1.7.1 > /dev/null 2>&1
gvm uninstall --force go1.8.1 > /dev/null 2>&1

##
## Install binary go
##

## No further binary tests needed for darwin.
