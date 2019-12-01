#!/bin/bash


#***************************[update]******************************************
# 2019 12 01

alias server_update="config_update_system"


#***************************[apt-cacher-ng]***********************************
# 2019 11 20

function server_config_aptcacher() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "sets the basic config of the apt-cacher-ng daemon."
    if [ $? -ne 0 ]; then return -1; fi

    # Do the configuration
    FILENAME_CONFIG="/etc/apt-cacher-ng/acng.conf"

    AWK_STRING="
        # config apt-cacher
        \$0 ~ /BindAddress: / {
          print \"# roboag:\",\$0
          \$0 = \"BindAddress: localhost 192.168.2.20\";
        }
        # 2019 11 20: removed offline mode - it is not useful anymore
        #\$0 ~ /^# Offlinemode/ {
        #  print \"# roboag:\",\$0
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
