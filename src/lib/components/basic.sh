#!/bin/bash

# Internal script, should never be used alone. Always use rdee.sh.

# This script holds functions for basic functionalities.
# *********************************************************
# WorkFlow

# 2023-12-12   Initialization, <is_array # init & utest>, <rexit # move>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Pre-check
# 1. ensuring this script should only be sourced by another
#    script rather than in CLI
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "The script can only be sourced rather than executed"
    exit 0
fi

if [[ -n "$1" && "$1" == "unload" ]]; then
    unset -f rexit function_exists is_array
    return
fi
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# system relative
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function rexit(){
    # this function aims to avoid exiting shell when source a script with `exit`
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        exit $1
    else
        return
    fi
}

function function_exists() {
    # this function aims to check if a named function exists
    # [-] Usage
    #    ● if function_exists echo_blue; then ecoh 2333; fi
    declare -f "$1" > /dev/null
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# variable relative
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function is_array() {
    # this function aims to test if the given variable name denotes to an array, from `declare -p`
    # doesn't support reference array by now

    local var_name=$1
    
    declare -p $var_name 2> /dev/null | grep -q '^declare \-[aA]'
    [[ $? == 0 ]] && { echo 1; return 0; } || { echo 0; return 101; }  # for compatibility
}


