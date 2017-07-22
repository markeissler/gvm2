##
## Unlike macOS, linux should be able to build old versions of Go.
##

##
## Build go
##

## Cleanup test objects
gvm uninstall go1.1.2 > /dev/null 2>&1
gvm uninstall go1.2.2 > /dev/null 2>&1
gvm uninstall go1.3.3 > /dev/null 2>&1
gvm uninstall go1.4.1 > /dev/null 2>&1
gvm uninstall go1.5.4 > /dev/null 2>&1
gvm uninstall go1.6.4 > /dev/null 2>&1

## 1.1.2
CGO_ENABLED=0 gvm install go1.1.2 #status=0
gvm list #status=0; match=/go1.1.2/

## 1.2.2
CGO_ENABLED=0 gvm install go1.2.2 #status=0
gvm list #status=0; match=/go1.2.2/

## 1.3.3
CGO_ENABLED=0 gvm install go1.3.3 #status=0
gvm list #status=0; match=/go1.3.3/

## 1.4.1 (1.4 would install current bootstrap version)
CGO_ENABLED=0 gvm install go1.4.1 #status=0
gvm list #status=0; match=/go1.4.1/

## 1.5.4
CGO_ENABLED=0 gvm install go1.5.4 #status=0
gvm list #status=0; match=/go1.5.4/

## 1.6.4
CGO_ENABLED=0 gvm install go1.6.4 #status=0
gvm list #status=0; match=/go1.6.4/

##
## Install binary go
##

## No further binary tests needed for linux.
