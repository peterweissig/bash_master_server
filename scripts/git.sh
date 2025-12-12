#!/bin/bash


# SERVER_CONFIG_GIT_STORAGE_PATH is exported in config.sh

#***************************[git user]****************************************
# 2020 01 08

function server_config_git_add_user() {

    temp="updates the git-user to add one more user for the git repos."
    git_home="/home/git/"
    git_ssh="${git_home}.ssh/"
    FILENAME_CONFIG="${git_ssh}authorized_keys"

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [<public-key-file>]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "    [#1:]optional path for public key file"
        echo "         e.g. ~/.ssh/id_rsa.pub"
        echo "This function $temp"
        echo "If path for key file is not set (e.g. \"\"), then the key"
        echo "must be entered manually when prompted."

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

    # check if git-user exists
    git_user="$(cat /etc/passwd | grep -e "^git")"
    if [ "$git_user" == "" ] || [ ! -d "$git_home" ]; then
        echo "$FUNCNAME: git-user or its home does not exist."
        echo "  Did you call server_config_git_init ?"
        return -2
    fi

    # load key
    key=""
    if [ "$1" != "" ]; then
        # check if key file exists
        if [ ! -e "$1" ]; then
            echo "$FUNCNAME: key file \"$1\" does not exist."
            return -3
        fi

        # load from key file
        key="$(cat "$1")"
        if [ $? -ne 0 ]; then return -4; fi
    else
        echo "Need a public key file for the user."
        echo "e.g. \"ssh-rsa AAAANzaC1yc2E...AvJICUvax2T9va5 egon@panther\""
        echo "Please paste the key file content and press enter:"
        echo -n "  "
        read key
        if [ $? -ne 0 ]; then return -5; fi
    fi

    # check key
    if [ "$key" == "" ]; then
        echo "$FUNCNAME: empty key."
        return -6
    fi

    if [ "${key:0:8}" != "ssh-rsa " ] && [ "${key:0:12}" != "ssh-ed25519 " ]; then
        echo "$FUNCNAME: key does neither start with \"ssh-rsa\" nor with \"ssh-ed25519\"."
        return -6
    fi

    # append key
    temp="no-port-forwarding,no-X11-forwarding"
    key_full="$temp,no-agent-forwarding,no-pty $key"

    # create ssh folder
    if sudo [ ! -d "$git_ssh" ]; then
        sudo mkdir -p  "$git_ssh" && \
        sudo chmod 700 "$git_ssh" && \
        sudo chown git "$git_ssh"
    fi
    if [ $? -ne 0 ]; then return -7; fi

    # create keyfile
    if sudo [ ! -e "$FILENAME_CONFIG" ]; then
        sudo touch     "$FILENAME_CONFIG" && \
        sudo chmod 600 "$FILENAME_CONFIG" && \
        sudo chown git "$FILENAME_CONFIG"
    fi
    if [ $? -ne 0 ]; then return -7; fi

    # load current file
    current_keys="$(sudo cat "$FILENAME_CONFIG")"
    if [ $? -ne 0 ]; then return -8; fi

    # check if key is already there
    temp="$(echo "$current_keys" | grep "$key" | wc -w )"
    if [ "$temp" -ne 0 ]; then
        echo "$FUNCNAME: key is already set."
        return -8
    fi

    # add key
    AWK_STRING="
        { print \$0 }

        # add public user key to git-user
        END {
            print \"$key_full\"
        }
    "
    _config_file_modify_full "$FILENAME_CONFIG" "git-user" \
      "$AWK_STRING" "normal" "" "sudo"
    if [ $? -ne 0 ]; then return -9; fi

    echo "done :-)"
}

# 2020 01 08
function server_config_git_list_users() {

    temp="lists all users for the git repos."
    git_home="/home/git/"
    FILENAME_CONFIG="${git_home}.ssh/authorized_keys"

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "This function $temp"

        return
    fi

    # check parameter
    if [ $# -gt 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check if git-user exists
    git_user="$(cat /etc/passwd | grep -e "^git")"
    if [ "$git_user" == "" ] || [ ! -d "$git_home" ]; then
        echo "$FUNCNAME: git-user or its home does not exist."
        echo "  Did you call server_config_git_init ?"
        return -2
    fi

    # load key file
    current_keys="$(sudo cat "$FILENAME_CONFIG")"
    if [ $? -ne 0 ]; then return -2; fi

    # list users
    echo "users in file \"$FILENAME_CONFIG\":"
    echo "$current_keys" | grep -E "^[^#]*ssh-rsa " | \
      grep -o -E "[^ ]+\$"
    if [ $? -ne 0 ]; then return -3; fi

    echo ""
    echo "done :-)"
}

#***************************[git repo]****************************************
# 2020 01 08

function server_config_git_create_repo() {

    temp="adds the given repo to the local server."
    git_path="${SERVER_CONFIG_GIT_STORAGE_PATH}"

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME [repo-name]"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0-1 parameters"
        echo "     #1: name of repo to be created"
        echo "         e.g. docs"
        echo "This function $temp"

        return
    fi

    # check parameter
    if [ $# -ne 1 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # init variables
    param_repo_name="$1"
    repo_full_name="${param_repo_name}.git"

    # check for user agreement
    _config_simple_parameter_check "$FUNCNAME" "" "$temp"
    if [ $? -ne 0 ]; then return -1; fi

    # repo-name
    temp="$(_file_name_clean_string "$param_repo_name")"
    if [ "$param_repo_name" != "$temp" ]; then
        echo "$FUNCNAME: repo name is not valid - try \"$temp\"."
        return -2
    fi

    # check if git-user exists
    git_user="$(cat /etc/passwd | grep -e "^git")"
    if [ "$git_user" == "" ] || [ ! -d "$git_path" ]; then
        echo "$FUNCNAME: git-user or the repo storage path does not exist."
        echo "  Did you call server_config_git_init ?"
        return -3
    fi

    # get real path
    git_real_path="$(sudo realpath "$git_path")/"
    if [ $? -ne 0 ]; then return -4; fi

    # read all dirs
    readarray -t filelist <<< "$(sudo ls --classify "${git_real_path}" | \
      grep -e "/\$" | grep -o -E "[^ /]+")"
    if [ $? -ne 0 ]; then return -5; fi

    # iterate over all files
    for i in ${!filelist[@]}; do
        if [ "${filelist[$i]}" == "$repo_full_name" ]; then
            echo -n "$FUNCNAME: repo $param_repo_name already exists"
            echo " in \"$git_real_path\"."
            return -6
        fi
    done

    # create repo
    repo_full_path="${git_real_path}${repo_full_name}/"
    sudo mkdir "${repo_full_path}" &&
      sudo git init --bare "${repo_full_path}" &&
      sudo chown -R git "${repo_full_path}"
    if [ $? -ne 0 ]; then return -6; fi

    echo "done :-)"
}

# 2020 01 09
function server_config_git_list_repos() {

    temp="lists all repo of the local server."
    git_path="${SERVER_CONFIG_GIT_STORAGE_PATH}"

    # print help
    if [ "$1" == "-h" ]; then
        echo "$FUNCNAME"

        return
    fi
    if [ "$1" == "--help" ]; then
        echo "$FUNCNAME needs 0 parameters"
        echo "This function $temp"

        return
    fi

    # check parameter
    if [ $# -gt 0 ]; then
        echo "$FUNCNAME: Parameter Error."
        $FUNCNAME --help
        return -1
    fi

    # check if git-user exists
    git_user="$(cat /etc/passwd | grep -e "^git")"
    if [ "$git_user" == "" ] || [ ! -d "$git_path" ]; then
        echo "$FUNCNAME: git-user or the repo storage path does not exist."
        echo "  Did you call server_config_git_init ?"
        return -3
    fi

    # get real path
    git_real_path="$(sudo realpath "$git_path")/"
    if [ $? -ne 0 ]; then return -3; fi

    echo "$git_real_path:"

    # list all repos
    #sudo ls --classify "${git_real_path}" | \
    #  grep -e "/\$" | grep -o -E "[^ /]+"
    sudo du --human-readable --max-depth=1 "${git_real_path}" | \
      grep -E "[^/]+\.git"
    if [ $? -ne 0 ]; then return -4; fi

    echo ""
    echo "done :-)"
}
