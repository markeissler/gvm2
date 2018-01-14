source "${SANDBOX}/gvm2/scripts/gvm"

##
## Test output messages
##

gvm update -h # status=0; match=/Usage: gvm update \[option\] \[<version>\]/
gvm update --help # status=0; match=/Usage: gvm update \[option\] \[<version>\]/

gvm update -l # status=0; match=/Available GVM2 versions/
gvm update --list # status=0; match=/Available GVM2 versions/

## Wait so that we don't get locked out for making too many git api requests
sleep 4

##
## find all versions available
##
## 0.9.0
## 0.9.1
## 0.9.2
## 0.10.0
## 0.10.1
## 0.10.2
## 0.10.3
## 0.10.4
## 0.10.5
## 0.10.6
##

## Setup expectation - nothing to do

## Execute command
availableVersions=( $(${SANDBOX}/gvm2/scripts/update --list --porcelain) )

## Evaluate result
for version in "${availableVersions[@]}";do [[ "${version}" == "v0.9.0" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "v0.9.1" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "v0.9.2" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "v0.10.0" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "v0.10.1" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "v0.10.2" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "v0.10.3" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "v0.10.4" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "v0.10.5" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "v0.10.6" ]] && break; done # status=0

## Wait so that we don't get locked out for making too many git api requests
sleep 4

## Switch to same version as installed
gvm update "v${GVM_VERSION}" # status=1; match=/GVM2 version is already installed/

## Switch to earlier release with update support (v0.10.5)
##
## NOTE: GVM2 >= v0.10.3 does not use git to update, we do not need to reset the
## git origin url to use https!
##
gvm update v0.10.5 # status=0; match=/to v0\.10\.5 \(from v[0-9]+\.[0-9]+\.[0-9]+\)/
source "${SANDBOX}/gvm2/scripts/gvm"
gvm version # status=0; match=/0.10.5/

## Switch to older release without update support (accept prompt)
##
## NOTE: GVM2 < v0.10.2 uses git to update, the default upstream url will use
## ssh instead of https and prompt for git user if not setup, so we will set one
## up now and then run the update test.
##
( builtin cd "${SANDBOX}/gvm2"; mv .git.bak .git; git remote set-url origin https://github.com/markeissler/gvm2.git; git -c user.name=test -c user.email=test@test.com commit -am "Pending"; mv .git .git.bak )
yes y | gvm update v0.9.1 # status=0
source "${SANDBOX}/gvm2/scripts/gvm"
gvm version # status=0; match=/0.9.1/

## Wait so that we don't get locked out for making too many git api requests
sleep 4

## Reset install on exit so other tests don't break!
( builtin cd "${SANDBOX}/gvm2"; mv git.bak .git; git reset --hard $(git rev-list --all --max-count=1); mv .git .git.bak )
