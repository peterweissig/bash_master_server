#!/bin/bash


#***************************[update]******************************************
# 2019 12 01

alias server_update="config_update_system"


#***************************[apt-cacher-ng]***********************************
# 2019 12 01

function server_config_aptcacher() {

    temp="sets the basic configuration of the apt-cacher-ng daemon."

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME <ip-address(es)>"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 1 parameter"
        echo "     #1: ip-address(es) of apt-cacher-ng server"
        echo "         if only localhost is needed, set to \"\""
        echo "This function $temp"

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "" "$temp"
    if [ $? -ne 0 ]; then return -1; fi

    # Do the configuration
    FILENAME_CONFIG="/etc/apt-cacher-ng/acng.conf"

    AWK_STRING="
        # config apt-cacher
        \$0 ~ /BindAddress: / {
          print \"# [EDIT]: \",\$0
          \$0 = \"BindAddress: localhost $1\";
        }
        # 2019 11 20: removed offline mode - it is not useful anymore
        #\$0 ~ /^# Offlinemode/ {
        #  print \"# [EDIT]: \",\$0
        #  \$0 = \"Offlinemode:1\";
        #}

        { print \$0 }
    "

    _config_file_modify "$FILENAME_CONFIG" "$AWK_STRING" "backup-once"
    if [ $? -ne 0 ]; then return -3; fi

    echo "restarting apt-cacher daemon"
    sudo systemctl restart apt-cacher-ng
    if [ $? -ne 0 ]; then return -4; fi

    echo "done :-)"
}

function server_config_aptcacher_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "restores the old behaviour of the apt-cacher-ng daemon."
    if [ $? -ne 0 ]; then return -1; fi

    # Undo the configuration
    FILENAME_CONFIG="/etc/apt-cacher-ng/acng.conf"

    _config_file_restore "$FILENAME_CONFIG" "backup-once"
    if [ $? -ne 0 ]; then return -2; fi

    echo "restarting apt-cacher-daemon"
    sudo systemctl restart apt-cacher-ng
    if [ $? -ne 0 ]; then return -3; fi

    echo "done :-)"
}
