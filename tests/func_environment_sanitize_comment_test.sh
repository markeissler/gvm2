g_path_script="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"
. "${g_path_script}/../scripts/function/gvm_environment_sanitize" || return 1

##
## sanitize system environment
##

## Setup expectation
sed -e "s%\${SANDBOX}%${SANDBOX}%g" "${SANDBOX}/gvm2/tests/func_environment_sanitize_test_input_system.sh" > "${SANDBOX}/gvm2/environments/system"
sed -e "s%\${SANDBOX}%${SANDBOX}%g" "${SANDBOX}/gvm2/tests/func_environment_sanitize_test_input_system@global.sh" > "${SANDBOX}/gvm2/environments/system@global"
mkdir "${SANDBOX}/gvm2/gos/system"

## 1.8.1
gvm uninstall go1.8.1 > /dev/null 2>&1
gvm install go1.8.1 --binary
source ${SANDBOX}/gvm2/scripts/gvm
gvm use go1.8.1

expectedSanitizedGOROOT="${SANDBOX}/gvm2/gos/go1.8.1"
expectedSanitizedConfig="$(grep "GOROOT" "${SANDBOX}/gvm2/environments/go1.8.1")"
## replace $GVM_ROOT with $SANDBOX/gvm2 path (system envs have static paths)
expectedSanitizedConfig="${expectedSanitizedConfig/\$GVM_ROOT/$SANDBOX\/gvm2}"

## Execute command
source ${SANDBOX}/gvm2/environments/system
gvm_environment_sanitize "system" "${SANDBOX}/gvm2/gos/go1.8.1/bin:$PATH}"
sanitizedGOROOT="${GOROOT}"
sanitizedConfig="$(grep "GOROOT" "${SANDBOX}/gvm2/environments/system")"

## Evaluate result
[[ "${sanitizedGOROOT}" == ${expectedSanitizedGOROOT} ]] # status=0
[[ "${sanitizedConfig}" == ${expectedSanitizedConfig} ]] # status=0

##
## sanitize system@global environment
##

## Setup expectation
sed -e "s%\${SANDBOX}%${SANDBOX}%g" "${SANDBOX}/gvm2/tests/func_environment_sanitize_test_input_system.sh" > "${SANDBOX}/gvm2/environments/system"
sed -e "s%\${SANDBOX}%${SANDBOX}%g" "${SANDBOX}/gvm2/tests/func_environment_sanitize_test_input_system@global.sh" > "${SANDBOX}/gvm2/environments/system@global"

## 1.8.1
gvm use go1.8.1

expectedSanitizedGOROOT="${SANDBOX}/gvm2/gos/go1.8.1"
expectedSanitizedConfig="$(grep "GOROOT" "${SANDBOX}/gvm2/environments/go1.8.1")"
## replace $GVM_ROOT with $SANDBOX/gvm2 path (system envs have static paths)
expectedSanitizedConfig="${expectedSanitizedConfig/\$GVM_ROOT/$SANDBOX\/gvm2}"

## Execute command
source ${SANDBOX}/gvm2/environments/system@global
gvm_environment_sanitize "system@global" "${SANDBOX}/gvm2/gos/go1.8.1/bin:$PATH}"
sanitizedGOROOT="${GOROOT}"
sanitizedConfig="$(grep "GOROOT" "${SANDBOX}/gvm2/environments/system@global")"

## Evaluate result
[[ "${sanitizedGOROOT}" == ${expectedSanitizedGOROOT} ]] # status=0
[[ "${sanitizedConfig}" == ${expectedSanitizedConfig} ]] # status=0

## Cleanup
rmdir "${SANDBOX}/gvm2/gos/system"
rm "${SANDBOX}/gvm2/environments/system@global"
rm "${SANDBOX}/gvm2/environments/system"
