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
ln --symbolic --force ${SOURCE_DIR}/.bashrc ~/.bashrc.mine
ln --symbolic --force ~/.bashrc.mine ~/.bashrc
ln --symbolic --force ${SOURCE_DIR}/.bash_aliases ~/.bash_aliases
ln --symbolic --force ${SOURCE_DIR}/.bash_functions ~/.bash_functions
ln --symbolic --force ${SOURCE_DIR}/tmux/.tmux.conf ~/.tmux.conf
