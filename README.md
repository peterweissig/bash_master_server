# bash_master_server
Master scripts for collection of server scripts.

## Setup for linux (Ubuntu)
create workspace directory

    mkdir -p ~/workspace
    cd ~/workspace


download scripts

    wget -nv https://raw.githubusercontent.com/PeterWeissig/bash_master_server/master/checkout.sh
    source checkout.sh


checkout additionals repositories (e.g. common bash scripts)

    repo_clone_bash
    repo_help #list of all referenced repositories

[![Build Status](https://travis-ci.org/PeterWeissig/bash_master_server.svg?branch=master)](https://travis-ci.org/PeterWeissig/bash_master_server)
