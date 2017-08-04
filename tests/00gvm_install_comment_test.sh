##
## Install test dependencies.
##
## The following versions of Go are buildable across all platforms and will be
## installed as local builds:
##  * 1.4 (will resolve to current 1.4 bootstrap)
##
## The following versions of Go are not buildable across all platforms and will
## be installed as binaries:
##  * 1.3.3.
##  * 1.2.2
##
## Additional build and binary install tests for All platforms are located in:
##  01gvm_install_all_comment_test.sh
##
## Beta (pre-release) versions of Go are updated regularly and are located in:
##  03gvm_install_beta_comment_test.sh
##

##
## Build go
##

## Cleanup test objects
gvm uninstall go1.4 > /dev/null 2>&1

## 1.4
gvm install go1.4 #status=0
gvm list #status=0; match=/go1.4/

##
## Install binary go (test dependencies)
##

## Cleanup test objects1
gvm uninstall go1.3.3 > /dev/null 2>&1
gvm uninstall go1.2.2 > /dev/null 2>&1

## 1.3.3
gvm install go1.3.3 --binary #status=0
gvm list #status=0; match=/go1.3.3/

## 1.2.2
gvm install go1.2.2 --binary #status=0
gvm list #status=0; match=/go1.2.2/
