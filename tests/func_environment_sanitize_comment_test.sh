source "${SANDBOX}/gvm2/scripts/function/environment_sanitize.sh" || return 1

##
## sanitize system environment
##

## Setup expectation

## 1.8.1
gvm uninstall --force go1.8.1 > /dev/null 2>&1
gvm install go1.8.1 --binary
source "${SANDBOX}/gvm2/scripts/gvm"
gvm use go1.8.1

## setup dummy system and system@global configs
sed -e "s%\${SANDBOX}%${SANDBOX}%g" "${SANDBOX}/gvm2/tests/func_environment_sanitize_test_input_system.sh" > "${SANDBOX}/gvm2/environments/system"
sed -e "s%\${SANDBOX}%${SANDBOX}%g" "${SANDBOX}/gvm2/tests/func_environment_sanitize_test_input_system@global.sh" > "${SANDBOX}/gvm2/environments/system@global"
mkdir "${SANDBOX}/gvm2/gos/system" > /dev/null 2>&1

expectedSanitizedGOROOT="${SANDBOX}/gvm2/gos/go1.8.1"
expectedSanitizedConfig="$(grep "GOROOT=" "${SANDBOX}/gvm2/environments/go1.8.1")"
## replace $GVM_ROOT with $SANDBOX/gvm2 path (system envs have static paths)
expectedSanitizedConfig="${expectedSanitizedConfig/\$\{GVM_ROOT\}/${SANDBOX}\/gvm2}"

## Execute command
source ${SANDBOX}/gvm2/environments/system
__gvm_environment_sanitize "system" "${SANDBOX}/gvm2/gos/go1.8.1/bin:${PATH}"
sanitizedGOROOT="${GOROOT}"
sanitizedConfig="$(grep "GOROOT=" "${SANDBOX}/gvm2/environments/system")"

## Evaluate result
[[ "${sanitizedGOROOT}" == ${expectedSanitizedGOROOT} ]] # status=0
[[ "${sanitizedConfig}" == ${expectedSanitizedConfig} ]] # status=0

##
## sanitize system@global environment
##

## 1.8.1
gvm use go1.8.1

## Setup expectation
sed -e "s%\${SANDBOX}%${SANDBOX}%g" "${SANDBOX}/gvm2/tests/func_environment_sanitize_test_input_system.sh" > "${SANDBOX}/gvm2/environments/system"
sed -e "s%\${SANDBOX}%${SANDBOX}%g" "${SANDBOX}/gvm2/tests/func_environment_sanitize_test_input_system@global.sh" > "${SANDBOX}/gvm2/environments/system@global"

expectedSanitizedGOROOT="${SANDBOX}/gvm2/gos/go1.8.1"
expectedSanitizedConfig="$(grep "GOROOT=" "${SANDBOX}/gvm2/environments/go1.8.1")"
## replace $GVM_ROOT with $SANDBOX/gvm2 path (system envs have static paths)
expectedSanitizedConfig="${expectedSanitizedConfig/\$\{GVM_ROOT\}/${SANDBOX}\/gvm2}"

## Execute command
source ${SANDBOX}/gvm2/environments/system@global
__gvm_environment_sanitize "system@global" "${SANDBOX}/gvm2/gos/go1.8.1/bin:$PATH}"
sanitizedGOROOT="${GOROOT}"
sanitizedConfig="$(grep "GOROOT=" "${SANDBOX}/gvm2/environments/system@global")"

## Evaluate result
[[ "${sanitizedGOROOT}" == ${expectedSanitizedGOROOT} ]] # status=0
[[ "${sanitizedConfig}" == ${expectedSanitizedConfig} ]] # status=0

## Cleanup test objects
gvm uninstall --force go1.1.2 > /dev/null 2>&1
rmdir "${SANDBOX}/gvm2/gos/system"
rm "${SANDBOX}/gvm2/environments/system@global"
rm "${SANDBOX}/gvm2/environments/system"
