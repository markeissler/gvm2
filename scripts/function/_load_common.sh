#!/usr/bin/env bash
# scripts/function/_common_load.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_LOAD_COMMON:-} -eq 1 ]] && return || readonly GVM_LOAD_COMMON=1

if [[ -n "$GVM_DEBUG" ]]
then
    printf "%s: \n" "${BASH_SOURCE[0]##*/}::loading common functions.."
fi

for function in ${GVM_ROOT}/scripts/function/*; do
    # function names preceded by an underscore should be loaded by other
    # scripts explicitly as needed.
    if [[ "${function##*/}" =~ ^_ ]]
    then
        continue
    fi
    [[ -n "$GVM_DEBUG" ]] && echo "  ${function}"
    source "${function}"
done
