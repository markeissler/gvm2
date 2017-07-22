##
## macOS (as of 10.12) can only build a subset of previous Go versions.
##

##
## find all source packages available for darwin
##
## 1.4 (will build 1.4-bootstrap)
## 1.7.1
## 1.8

## Setup expectation - nothing to do

## Execute command
availableVersions=( $(${SANDBOX}/gvm2/scripts/listall --source --porcelain) )

## Evaluate result
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.4" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.7.1" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.8" ]] && break; done # status=0

for version in "${availableVersions[@]}";do [[ "${version}" == "go1.2" ]] && break; done # status=1
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.3" ]] && break; done # status=1
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.5" ]] && break; done # status=1
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.6" ]] && break; done # status=1
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.7" ]] && break; done # status=1

##
## find all binary packages available for darwin
##
## 1.2
## 1.3
## 1.4
## 1.5
## 1.6
## 1.7
## 1.8

## Wait so that we don't get locked out for making too many git api requests
sleep 4

## Execute command
availableVersions=( $(${SANDBOX}/gvm2/scripts/listall --binary --porcelain) )

## Evaluate result
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.2.2" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.3" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.3.1" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.4" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.5" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.6" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.7" ]] && break; done # status=0
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.8" ]] && break; done # status=0

for version in "${availableVersions[@]}";do [[ "${version}" == "go1.1" ]] && break; done # status=1
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.2" ]] && break; done # status=1
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.2.1" ]] && break; done # status=1
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.3beta1" ]] && break; done # status=1
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.4beta1" ]] && break; done # status=1
for version in "${availableVersions[@]}";do [[ "${version}" == "go1.8rc2" ]] && break; done # status=1
