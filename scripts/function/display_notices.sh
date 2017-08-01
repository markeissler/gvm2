# scripts/function/display_notices.sh
#
# shellcheck shell=bash
# vi: set ft=bash
#
# Display error messages of various severity to user.
#

# source once and only once!
[[ ${GVM_DISPLAY_NOTICES:-} -eq 1 ]] && return || readonly GVM_DISPLAY_NOTICES=1

__gvm_display_error() {
    command -v tput &> /dev/null
    if [[ "$?" == "0" ]]  && [[ "$TERM" == "xterm" ]]; then
        tput sgr0
        tput setaf 1
        echo "ERROR: $1" >&2
        tput sgr0
    else
        echo "ERROR: $1" >&2
    fi
    return 1
}

__gvm_display_fatal() {
    command -v tput &> /dev/null
    if [[ "$?" == "0" ]]  && [[ "$TERM" == "xterm" ]]; then
        tput sgr0
        tput setaf 1
        echo "ERROR: $1" >&2
        tput sgr0
    else
        echo "ERROR: $1" >&2
    fi
    exit 1
}

__gvm_display_message() {
    command -v tput &> /dev/null
    if [[ "$?" == "0" ]]  && [[ "$TERM" == "xterm" ]]; then
        # GREEN!
        tput sgr0
        tput setaf 2
        echo "$1"
        tput sgr0
    else
        echo "$1"
    fi
}

__gvm_display_warning() {
    command -v tput &> /dev/null
    if [[ "$?" == "0" ]]  && [[ "$TERM" == "xterm" ]]; then
        # YELLOW!
        tput sgr0
        tput setaf 3
        echo "WARNING: $1"
        tput sgr0
    else
        echo "$1"
    fi
    return 1
}
