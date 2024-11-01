#!/bin/bash


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "The script can only be sourced rather than executed"
    exit 0
fi

if [[ -n "$1" && "$1" == "unload" ]]; then
    echo $__rdeebash_filedir__
    source $__rdeebash_filedir__/components/basic.sh unload
    source $__rdeebash_filedir__/components/io.sh unload
    source $__rdeebash_filedir__/components/sh.sh unload
    source $__rdeebash_filedir__/components/time.sh unload
    source $__rdeebash_filedir__/components/array.sh unload
    source $__rdeebash_filedir__/components/string.sh unload

    unset __rdeebash_file__ __rdeebash_filedir__
    return
fi

#@ Prepare
__rdeebash_file__=$(realpath "${BASH_SOURCE[0]}")
__rdeebash_filedir__=$(dirname $__rdeebash_file__)


source $__rdeebash_filedir__/components/basic.sh
source $__rdeebash_filedir__/components/io.sh
source $__rdeebash_filedir__/components/sh.sh
source $__rdeebash_filedir__/components/time.sh
source $__rdeebash_filedir__/components/array.sh
source $__rdeebash_filedir__/components/string.sh


# export RDEE_LOADED=1
