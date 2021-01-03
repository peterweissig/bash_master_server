#!/bin/bash


#***************************[all]*********************************************
# 2021 01 03

function server_help_all() {

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo -n "Prints all available functions within server repository "
        echo "\"server\"."

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # print overview of all repositories
    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help"
    echo -n "  "; echo "server_help  #no help"
    echo -n "  "; $FUNCNAME -h
    echo ""
    if [ "$SOURCED_BASH_CONFIG" != "" ]; then
        echo -n "  "; echo "config_help                 #no help"
    fi
    if [ "$SOURCED_BASH_FILE" != "" ]; then
        echo -n "  "; echo "file_help                   #no help"
    fi
    if [ "$SOURCED_BASH_MULTIMEDIA" != "" ]; then
        echo -n "  "; echo "multimedia_help             #no help"
    fi
    if [ "$SOURCED_BASH_NETWORK" != "" ]; then
        echo -n "  "; echo "network_help                #no help"
    fi
    if [ "$SOURCED_BASH_REPO" != "" ]; then
        echo -n "  "; echo "repo_help                   #no help"
    fi
    echo ""
    echo "repository functions"
    echo -n "  "; echo "server_repo_status          #no help"
    echo -n "  "; echo "server_repo_update          #no help"
    echo ""
    echo "install functions"
    echo -n "  "; echo "server_update               #no help"
    echo -n "  "; server_config_aptcacher -h
    echo -n "  "; server_config_git_init -h
    echo ""
    echo "git functions"
    echo -n "  "; server_config_git_add_user -h
    echo -n "  "; server_config_git_list_users -h
    echo -n "  "; server_config_git_create_repos -h
    echo -n "  "; server_config_git_list_repos -h
    echo ""
    echo "check functions"
    echo -n "  "; echo "server_config_aptcacher_check  #no help"
    echo ""
}

#***************************[help]********************************************
# 2021 01 03

function server_help() {

    echo ""
    echo "### $FUNCNAME ###"
    echo ""
    echo "help functions"
    echo -n "  "; echo "$FUNCNAME                   #no help"
    echo -n "  "; server_help_all -h
    echo ""
    echo "repository functions"
    echo -n "  "; echo "server_repo_status          #no help"
    echo -n "  "; echo "server_repo_update          #no help"
    echo ""
    echo "install functions"
    echo -n "  "; echo "server_update               #no help"
    echo -n "  "; server_config_aptcacher -h
    echo -n "  "; server_config_git_init -h
    echo ""
    echo "git functions"
    echo -n "  "; server_config_git_add_user -h
    echo -n "  "; server_config_git_list_users -h
    echo -n "  "; server_config_git_create_repos -h
    echo -n "  "; server_config_git_list_repos -h
    echo ""
    echo "check functions"
    echo -n "  "; echo "server_config_aptcacher_check  #no help"
    echo ""
}
