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

#***************************[git_repo]****************************************
# 2020 01 05

alias server_config_git_add_user="echo '...todo...'"
alias server_config_git_create_repo="echo '...todo...'"

function server_config_git_init() {

    temp="sets up basic configurations to add git repos."
    official_storage_path="/srv/git"

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<storage-path>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]optional path for storing git repos"
        echo "         (default $official_storage_path)"
        echo "This function $temp"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "" "$temp"
    if [ $? -ne 0 ]; then return -1; fi

    # init variables
    param_storage_path="$1"
    if [ $# -lt 1 ]; then
        param_storage_path="$official_storage_path"
    fi

    # config git-shell
        FILENAME_CONFIG_SHELL="/etc/shells"

        # check if git-shell exists
        git_shell="$(which git-shell)"
        if [ $? -ne 0 ] || [ "$git_shell" == "" ]; then
            echo "$FUNCNAME: git-shell does not exist."
            echo "  Is \"git\" installed ?"
            return -2
        fi

        # check if git-shell is available
        temp="$(cat "$FILENAME_CONFIG_SHELL" | grep -e "^${git_shell}\$")"
        if [ "$temp" == "" ]; then
            AWK_STRING_SHELL="
                { print \$0 }

                # add git-shell to login-shell
                END {
                    print \"$git_shell\"
                }
            "
            _config_file_modify "$FILENAME_CONFIG_SHELL" "$AWK_STRING_SHELL"
            if [ $? -ne 0 ]; then return -3; fi
        fi

    # config git-user
        # check if git-user exists
        git_user="$(cat /etc/passwd | grep -e "^git")"
        if [ "$git_user" == "" ]; then
            # add git user
            echo "Creating git-user soon - please insert the following:"
            echo "    Vollständiger Name  : git-user"
            echo "    Zimmernummer        : \"\" (leave empty)"
            echo "    Telefon geschäftlich: \"\" (leave empty)"
            echo "    Telefon privat      : \"\" (leave empty)"
            echo "    Sonstiges           : \"\" (leave empty)"
            echo ""
            echo "    Ist diese Information richtig? [J/N] (push enter)"
            echo ""

            sudo adduser --disabled-password --shell "$git_shell" git && \
              sudo chmod go= "/home/git/"
                #sudo passwd -l git
                #sudo chsh git
            if [ $? -ne 0 ]; then return -4; fi
        fi

    # create database (base of repositories)
        # check if database folder exists
        if [ ! -d "$param_storage_path" ]; then
            # create database folder
            echo "creating storage path"
            sudo mkdir -p "$param_storage_path"
            if [ $? -ne 0 ]; then return -5; fi
        fi

        # set owner & mode of database-folder
        sudo chown git:git "$param_storage_path" && \
          sudo chmod go= "$param_storage_path"
        if [ $? -ne 0 ]; then return -6; fi

        # add link from official storage path
        # check storage path
        if [ ! -e "$official_storage_path" ]; then
            # create softlink
            echo "adding symbolic link"
            echo "    ($official_storage_path -> $param_storage_path)"
            sudo ln -s -T "$param_storage_path" "$official_storage_path"
            if [ $? -ne 0 ]; then return -7; fi
        fi

    echo ""
    echo "You may add ssh-users (having access to all repos):"
    echo "    $ server_config_git_add_user"
    echo "You may create repositories (for all users):"
    echo "    $ server_config_git_create_repo"
    echo ""

    echo "done :-)"
}

function server_config_git_init_restore() {

    # print help and check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "$1" \
      "removes all git components - repo database is not touched."
    if [ $? -ne 0 ]; then return -1; fi

    # check if git-user exists
    git_user="$(cat /etc/passwd | grep -e "^git")"
    if [ "$git_user" != "" ]; then
        # remove git-user
        echo "remove user git"
        sudo deluser git --remove-home
        if [ $? -ne 0 ]; then return -2; fi
    fi

    # remove git-shell
    FILENAME_CONFIG_SHELL="/etc/shells"

    temp="$(_config_file_return_last "$FILENAME_CONFIG_SHELL")"
    if [ "$temp" != "" ]; then
        _config_file_restore "$FILENAME_CONFIG_SHELL"
        if [ $? -ne 0 ]; then return -3; fi
    fi

    # remove link
    official_storage_path="/srv/git"

    if [ -L "$official_storage_path" ]; then
        echo "removing symbolic link $official_storage_path"
        sudo rm "$official_storage_path"
    fi

    echo "done :-)"
}
