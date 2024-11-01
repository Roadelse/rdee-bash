
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "The script can only be sourced rather than executed"
    exit 0
fi

if [[ -n "$1" && "$1" == "unload" ]]; then
    if [[ -n "$__rdeebash_file__" ]]; then
        qR
    fi
    unset -f iR qR
    return
fi


__rdeebash_file__=$(realpath "${BASH_SOURCE[0]}")
__rdeebash_filedir__=$(dirname $__rdeebash_file__)
__rdeesh__=$__rdeebash_filedir__/rdee.sh
unset __rdeebash_file__ __rdeebash_filedir__

function iR(){
    source $__rdeesh__ load
}


function qR(){
    source $__rdeesh__ unload
}
