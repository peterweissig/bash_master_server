#!/bin/bash

#***************************[needed external variables]***********************
# 2019 12 01

# SERVER_PATH_WORKSPACE



#***************************[server]******************************************
# 2019 12 01

# note: this is already set in file bash/repo/list.sh
export REPO_ROOT_GITHUB_URL="https://github.com/peterweissig/"



#***************************[bash]********************************************
# 2024 01 26

if [ "$SOURCED_BASH_REPO" == "" ]; then
  # paths
  # note: this is already set in file bash/repo/list.sh
  export REPO_BASH_PATH="${SERVER_PATH_WORKSPACE}bash/"
  export REPO_BASH_MASTER_PATH="${REPO_BASH_PATH}master/"

  # repos
  # note: this is already set in file bash/repo/list.sh
  export REPO_BASH_REPO=("${REPO_BASH_PATH}repo/" \
    "${REPO_ROOT_GITHUB_URL}bash_repo.git")

  function git_clone_bash_repo()  { _repo_git_clone ${REPO_BASH_REPO[*]};  }
  function git_pull_bash_repo()   { _repo_git_pull "${REPO_BASH_REPO[0]}"; }
  function git_push_bash_repo()   { _repo_git_push "${REPO_BASH_REPO[0]}"; }
  function git_status_bash_repo() { _repo_git_st   "${REPO_BASH_REPO[0]}"; }

  # main scripts
  # note: this is already set in file bash/repo/list.sh
  export REPO_BASH_MASTER_SERVER=("${REPO_BASH_MASTER_PATH}server/" \
    "${REPO_ROOT_GITHUB_URL}bash_master_server.git")

  function git_clone_bash_master_server() {
      _repo_git_clone ${REPO_BASH_MASTER_SERVER[*]}
  }
  function git_pull_bash_master_server() {
      _repo_git_pull "${REPO_BASH_MASTER_SERVER[0]}"
  }
  function git_push_bash_master_server() {
      _repo_git_push "${REPO_BASH_MASTER_SERVER[0]}"
  }
  function git_status_bash_master_server() {
      _repo_git_st "${REPO_BASH_MASTER_SERVER[0]}"
  }
fi



#***************************[global update and stat]**************************
# 2023 11 18

function server_repo_update() { repo_pull_all;   }
function server_repo_status() { repo_status_all; }

