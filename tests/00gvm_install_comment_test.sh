##
## All platforms should be able to build these versions of GO:
##  * 1.4 (will resolve to current 1.4 bootstrap)
##  * 1.7.1+
##
## All platforms should be able to install these binary versions:
##  * 1.2+
##

##
## Build go
##

## Cleanup test objects
gvm uninstall go1.4 > /dev/null 2>&1
gvm uninstall master > /dev/null 2>&1
gvm uninstall go1.7.5 > /dev/null 2>&1

## 1.4
gvm install go1.4 #status=0
gvm list #status=0; match=/go1.4/

## master
##GOROOT_BOOTSTRAP=$GVM_ROOT/gos/go1.4 gvm install master #status=0
CGO_ENABLED=0 gvm install master #status=0
gvm list #status=0; match=/master/

## 1.7.5
CGO_ENABLED=0 gvm install go1.7.5 #status=0
gvm list #status=0; match=/go1.7.5/

## 1.8.2
CGO_ENABLED=0 gvm install go1.8.2 #status=0
gvm list #status=0; match=/go1.8.2/

## Beta releases are in 02gvm_install_beta_comment_test.sh!

##
## Install binary go
##

## Cleanup test objects
gvm uninstall go1.6.4 > /dev/null 2>&1
gvm uninstall go1.5.4 > /dev/null 2>&1
gvm uninstall go1.3.3 > /dev/null 2>&1
gvm uninstall go1.2.2 > /dev/null 2>&1

## 1.6.4
gvm install go1.6.4 --binary #status=0
gvm list #status=0; match=/go1.6.4/

## 1.5.4
gvm install go1.5.4 --binary #status=0
gvm list #status=0; match=/go1.5.4/

## 1.3.3
gvm install go1.3.3 --binary #status=0
gvm list #status=0; match=/go1.3.3/

## 1.2.2
gvm install go1.2.2 --binary #status=0
gvm list #status=0; match=/go1.2.2/
