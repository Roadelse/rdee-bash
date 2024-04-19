#!/bin/bash

scriptPath=$(readlink -f "${BASH_SOURCE[0]}")
scriptDir=$(dirname $scriptPath)
# echo $scriptPath
# echo $scriptDir

source $scriptDir/_components/_basic.sh
source $scriptDir/_components/_io.sh
source $scriptDir/_components/_os.sh
source $scriptDir/_components/_time.sh
source $scriptDir/_components/_array.sh
source $scriptDir/_components/_string.sh

# export RDEE_LOADED=1
