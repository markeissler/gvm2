##
## All platforms should be able to build these versions of Go:
##  * 1.4 (will resolve to current 1.4 bootstrap)
##  * 1.7.1+
##
## All platforms should be able to install these binary versions:
##  * 1.2+
##
## Beta releases are in 02gvm_install_beta_comment_test.sh!
##

##
## Build go
##

## Cleanup test objects
gvm uninstall --force master > /dev/null 2>&1
gvm uninstall --force go1.7.5 > /dev/null 2>&1
gvm uninstall --force go1.8.2 > /dev/null 2>&1

## master
##GOROOT_BOOTSTRAP=${SANDBOX}/gvm2/gos/go1.4 gvm install master #status=0
CGO_ENABLED=0 gvm install master #status=0
gvm list #status=0; match=/master/

## 1.7.5
CGO_ENABLED=0 gvm install go1.7.5 #status=0
gvm list #status=0; match=/go1.7.5/

## 1.8.2
CGO_ENABLED=0 gvm install go1.8.2 #status=0
gvm list #status=0; match=/go1.8.2/

##
## Install binary go
##

## Cleanup test objects
gvm uninstall --force go1.6.4 > /dev/null 2>&1
gvm uninstall --force go1.5.4 > /dev/null 2>&1

## 1.6.4
gvm install go1.6.4 --binary #status=0
gvm list #status=0; match=/go1.6.4/

## 1.5.4
gvm install go1.5.4 --binary #status=0
gvm list #status=0; match=/go1.5.4/

## Cleanup test objects
gvm uninstall --force go1.6.4 > /dev/null 2>&1
gvm uninstall --force go1.5.4 > /dev/null 2>&1
