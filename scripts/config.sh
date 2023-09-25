#!/bin/bash


#***************************[update]******************************************
# 2019 12 01

alias server_update="config_update_system"


#***************************[apt-cacher-ng]***********************************
# 2023 09 23

function server_config_aptcacher_check() {

    # no output per default

    # check if apt-cacher-ng is installed
    if config_install_show | grep apt-cacher-ng || \
      config_check_service apt-cacher-ng "quiet" "" "" > /dev/null; then
        echo "apt-cacher-ng     ... is still installed"
        echo "                    --> sudo apt purge apt-cacher-ng"
        echo "                    --> sudo rm -rf /var/cache/apt-cacher-ng/"
    fi
}



#***************************[git_repo]****************************************

export SERVER_CONFIG_GIT_STORAGE_PATH="/srv/git"

# 2021 01 03
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
        echo "         (default $SERVER_CONFIG_GIT_STORAGE_PATH)"
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
        param_storage_path="$SERVER_CONFIG_GIT_STORAGE_PATH"
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
            sudo adduser --disabled-password --shell "$git_shell" \
              --gecos "git-user" git && \
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
        temp="$SERVER_CONFIG_GIT_STORAGE_PATH"
        if [ ! -e "$temp" ]; then
            # create softlink
            echo "adding symbolic link"
            echo "    ($temp -> $param_storage_path)"
            sudo ln -s -T "$param_storage_path" "$temp"
            if [ $? -ne 0 ]; then return -7; fi
        fi

    echo ""
    echo "You may hide the git-user from login:"
    echo "    $ config_users_hide_login git"
    echo "You may add ssh-users (having access to all repos):"
    echo "    $ server_config_git_add_user"
    echo "You may create repositories (for all users):"
    echo "    $ server_config_git_create_repo"
    echo ""

    echo "done :-)"
}

# 2020 01 26
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
