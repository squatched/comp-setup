#!/bin/bash

set -eou pipefail
IFS=$'\n\t'

# Won't work in 100% of our cases (http://mywiki.wooledge.org/BashFAQ/028) but it'll do for now.
pushd "${BASH_SOURCE[@]%/*}/" >/dev/null
SOURCE_DIR=$(pwd)
popd >/dev/null

# Cache off the original .bashrc if it exists and has not already been created as a link.
if [[ ! -L ~/.bashrc && -e ~/.bashrc && ! -e ~/.bashrc.original ]]; then
    echo "Moving original .bashrc to .bashrc.original."
    mv ~/.bashrc ~/.bashrc.original
fi
ln --symbolic --force ${SOURCE_DIR}/.bashrc ${HOME}/.bashrc.mine
ln --symbolic --force ~/.bashrc.mine ${HOME}/.bashrc
ln --symbolic --force ${SOURCE_DIR}/.bash_aliases ${HOME}/
ln --symbolic --force ${SOURCE_DIR}/.bash_functions ${HOME}/
ln --symbolic --force ${SOURCE_DIR}/.bash_script_env ${HOME}/
ln --symbolic --force ${SOURCE_DIR}/.bash_environment_global ${HOME}/
ln --symbolic --force ${SOURCE_DIR}/tmux/.tmux.conf ${HOME}/
ln --symbolic --force ${SOURCE_DIR}/.pam_environment ${HOME}/
