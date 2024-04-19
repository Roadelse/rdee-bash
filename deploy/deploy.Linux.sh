#!/bin/bash

#@ Introduction
###############################################################################
# This scripts aims to deploy the rdee-bash in system                         #
# Support flexible deployment method, inlcuding:                              #
#    ● setenv bash script                                                     #
#    ● modulefile                                                             #
# ----------------------------------------------------------------------------#
#                                                                             #
# 2024-04-17  Roadelse  Initialized                                           #
###############################################################################

#@ Prepare
#@ .
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo -e "\033[31mError!\033[0m The script can only be executed rather than be sourced!"
    exit 101
fi
scriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && readlink -f .)
workDir=$PWD
cd $scriptDir

#@ .preliminary-functions
function error() {
    echo -e '\033[31m'"Error"'\033[0m' "$1"
    exit 101
}
function success() {
    echo -e '\033[32m'"$1"'\033[0m'
}
function progress() {
    echo -e '\033[33m-- '"($(date '+%Y/%m/%d %H:%M:%S')) ""$1"'\033[0m'
}

#@ <.pre-check>
#@ <..python3>
if [[ -z $(which python 2>/dev/null) ]]; then
    error "Cannot find python interpreter"
fi
pyver=$(python --version | cut -d' ' -f2)
if [[ $(echo $pyver | cut -d. -f1) != 3 || $(echo $pyver | cut -d. -f2) -lt 6 ]]; then
    error "Python version is too old: $pyver, while out requirement is at least 3.6"
fi

#@ <.arguments>
#@ <..default>
deploy_mode="setenv"
profile=
show_help=0
modulepath=
utest=0
verbose=0
#@ <..resolve>
while getopts "hd:p:m:uv" arg; do
    case $arg in
    h)
        show_help=1
        ;;
    u)
        utest=1
        ;;
    d)
        deploy_mode=$OPTARG
        ;;
    p)
        profile=$OPTARG
        ;;
    m)
        modulepath=$OPTARG
        ;;
    v)
        verbose=1
        ;;
    ?)
        error "Unknown option: $OPTARG"
        ;;
    esac
done

#@ .help
if [[ $show_help == 1 ]]; then
    echo "
deploy.Linux.sh [options]

[options]
    ● -h
        show this information
    ● -d deploy_mode
        select deployment target, supporting install, append, setenv, setenv+, module, module+
    ● -p profile
        select profile to be added
    ● -m modulepath
        set modulepath to put generated modulefile
    ● -u
        Do unit test
    ● -v
        Turn on verbose mode
"
    exit 0
fi

#@ .dependent-variables
VERSION=$(cat $scriptDir/../VERSION)
proj=$(basename $(realpath $scriptDir/..))

#@ Core
if [[ $utest == 0 ]]; then
    mkdir -p $scriptDir/export/libin
    ln -sf $scriptDir/../src/rdee.sh $scriptDir/export/libin
    text_setenv="# >>>>>>>>>>>>>>>>>>>>>>>>>>> [$proj]
export PATH=${scriptDir}/export/libin:\$PATH
alias iR='source ${scriptDir}/export/libin/rdee.sh'

"
    if [[ $deploy_mode == "setenv" ]]; then
        echo "$text_setenv" >$scriptDir/export/setenv.$proj.sh
        success "Succeed to generate setenv script: $scriptDir/export/setenv.$proj.sh"

        if [[ -n $profile ]]; then
            cat <<EOF >.temp.$proj
# >>>>>>>>>>>>>>>>>>>>>>>>>>> [$proj]
source $scriptDir/export/setenv.$proj.sh

EOF
            python $scriptDir/tools/fileop.ra-block.py $profile .temp.$proj

            if [[ $? -eq 0 ]]; then
                success "Succeed to add source statements in $profile"
            else
                error "Failed add source statements in $profile"
            fi
            rm -f .temp.$proj
        fi

    elif [[ $deploy_mode == "setenv+" ]]; then
        if [[ -z $profile ]]; then
            error "Must provide profile in setenv+ deploy mode"
        fi
        echo "$text_setenv" >.temp.$proj
        python $scriptDir/tools/fileop.ra-block.py $profile .temp.$proj
        if [[ $? -eq 0 ]]; then
            success "Succeed to add setenv statements in $profile"
        else
            error "Failed to add setenv statements in $profile"
        fi
        rm -f .temp.$proj

    elif [[ $deploy_mode =~ "module" ]]; then
        mkdir -p $scriptDir/export/modulefiles/$proj
        cat <<EOF >$scriptDir/export/modulefiles/$proj/default
#%Module1.0

prepend-path PATH $scriptDir/export/libin
set-alias iR {source ${scriptDir}/export/libin/rdee.sh}


EOF
        success "Succeed to generate modulefile in $scriptDir/export/modulefiles"

        if [[ $deploy_mode == "module" && -n "$profile" ]]; then
            cat <<EOF >.temp.$proj
# >>>>>>>>>>>>>>>>>>>>>>>>>>> [$proj]
module use $scriptDir/export/modulefiles

EOF
            python $scriptDir/tools/fileop.ra-block.py $profile .temp.$proj
            if [[ $? -eq 0 ]]; then
                success "Succeed to add 'module use' statements in $profile"
            else
                error "Failed to add 'module use' statements in $profile"
            fi
            rm -f .temp.$proj

        elif [[ $deploy_mode == "module+" ]]; then
            if [[ -z "$modulepath" ]]; then
                error "module+ mode required modulepath provided"
            fi
            if [[ ! -d "$modulepath" ]]; then
                error "modulepath must be an existed directory"
            fi
            ln -sfT $scriptDir/export/modulefiles/$proj $modulepath/$proj
            if [[ $? -eq 0 ]]; then
                success "Succeed to put modulefiles into modulepath=$modulepath"
            else
                error "Failed to put modulefiles into modulepath=$modulepath"
            fi
        fi
    else
        error "Unexpected deploy_mode=${deploy_mode}"
    fi

else
    #@ utest
    progress "Start unit test for deployment ..."

    testCommand='alias iR >& /dev/null'
    PATH_ori="$PATH"
    cd $scriptDir

    #@ .test-setenv
    progress "deploy via setenv mode"

    bash ./deploy.Linux.sh -d setenv >&/dev/null
    if [[ ! -e $scriptDir/export/setenv.$proj.sh ]]; then
        error "Failed to deploy $proj via setenv deploy-mode"
    fi
    bash ./deploy.Linux.sh -d setenv -p test.sh >&/dev/null
    if [[ $? != 0 ]]; then
        error "Failed to deploy $proj via setenv deploy-mode with profile together"
    fi
    . test.sh
    eval $testCommand
    if [[ $? != 0 ]]; then
        error "Failed to load $proj via setenv deploy-mode with profile together"
    fi
    success "setenv mode passed"
    rm -rf export
    rm test.sh

    unalias iR
    export PATH="$PATH_ori"

    #@ .test-setenv+
    progress "deploy via setenv+ mode"

    bash ./deploy.Linux.sh -d setenv+ >&/dev/null
    if [[ $? -eq 0 ]]; then
        error "Failed to deploy $proj via setenv+ deploy-mode, no -p ... but script exit with 0"
    fi

    bash ./deploy.Linux.sh -d setenv+ -p test2.sh >&/dev/null
    if [[ $? != 0 ]]; then
        error "Failed to deploy $proj via setenv+ deploy-mode with profile together"
    fi
    . test2.sh
    eval $testCommand
    if [[ $? != 0 ]]; then
        error "Failed to load $proj via setenv+ deploy-mode with profile together"
    fi
    success "setenv+ mode passed"
    rm -rf export
    rm test2.sh

    unalias iR
    export PATH="$PATH_ori"

    #@ .test-module
    progress "deploy via module mode"

    bash ./deploy.Linux.sh -d module >&/dev/null
    if [[ ! -e $scriptDir/export/modulefiles/$proj ]]; then
        error "Failed to deploy $proj via module deploy-mode"
    fi
    if module list 2>/dev/null; then
        bash ./deploy.Linux.sh -d module -p test2.sh >&/dev/null
        . test2.sh
        module load $proj
        eval $testCommand
        if [[ $? != 0 ]]; then
            error "Failed to deploy $proj via module deploy-mode with profile together"
        fi
        progress "works well via modulefile"
        module unload $proj
        rm test2.sh
    fi
    success "module mode passed"

    rm -rf export

    #@ .test-module+
    progress "deploy via module+ mode"

    bash ./deploy.Linux.sh -d module+ -m tools >&/dev/null
    if [[ ! -d tools/$proj ]]; then
        error "Failed to deploy $proj via module+ deploy-mode"
    fi
    rm -f tools/$proj
    success "module+ mode passed"

    rm -rf export
fi
