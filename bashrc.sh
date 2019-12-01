#!/bin/bash

#***************************[check if already sourced]************************
# 2019 12 01

if [ "$SOURCED_BASH_MASTER_SERVER" != "" ]; then

    return
    exit
fi

if [ "$SOURCED_BASH_LAST" == "" ]; then
    export SOURCED_BASH_LAST=1
else
    export SOURCED_BASH_LAST="$(expr "$SOURCED_BASH_LAST" + 1)"
fi

export SOURCED_BASH_MASTER_SERVER="$SOURCED_BASH_LAST"


#***************************[paths and files]*********************************
# 2019 12 01

export SERVER_PATH_SCRIPT="$(cd "$(dirname "${BASH_SOURCE}")" && pwd )/"
export SERVER_PATH_WORKSPACE="$(cd "${SERVER_PATH_SCRIPT}../../../" && \
  pwd )/"


#***************************[help]********************************************
# 2019 12 01

. ${ROBO_PATH_SCRIPT}scripts/help.sh


#***************************[repository]**************************************
# 2019 12 01

. ${SERVER_PATH_SCRIPT}scripts/repository.sh

if [ -d "${REPO_BASH_REPO[0]}" ]; then
    export REPO_PATH_WORKSPACE="${SERVER_PATH_WORKSPACE}"
    . ${REPO_BASH_REPO[0]}bashrc.sh
fi


#***************************[config]******************************************
# 2019 12 01

. ${ROBO_PATH_SCRIPT}scripts/config.sh


#***************************[simple bash scripts]*****************************
# 2019 12 01

if [ -d "${REPO_BASH_MASTER_BASHONLY[0]}" ]; then
    . ${REPO_BASH_MASTER_BASHONLY[0]}bashrc.sh
fi
