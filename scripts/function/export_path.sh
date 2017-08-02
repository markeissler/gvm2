# scripts/function/export_path.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#

# source once and only once!
[[ ${GVM_EXPORT_PATH:-} -eq 1 ]] && return || readonly GVM_EXPORT_PATH=1

# load dependencies
dep_load() {
    local base="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"
    local deps; deps=(
        "tools"
    )
    for file in "${deps[@]}"
    do
        source "${base}/${file}"
    done
}; dep_load

# __gvm_export_path()
# /*!
# @abstract Exports an updated PATH for current value of GVM_ROOT.
# @return Always returns success (status 0).
# */
__gvm_export_path() {
    [[ "${GVM_DEBUG}" -eq 1 ]] && echo "__gvm_export_path() - Original path: ${PATH}"
      export PATH="${GVM_ROOT}/bin:$(echo "${PATH}" | tr ":" "\n" | "${GREP_PATH}" -v '^$' | egrep -v "${GVM_ROOT}/(pkgsets|gos|bin)" | tr "\n" ":" | sed 's/:*$//')"
      export GVM_PATH_BACKUP="${PATH}"
    [[ "${GVM_DEBUG}" -eq 1 ]] && echo "__gvm_export_path() - Updated path: ${PATH}"

    return 0
}
