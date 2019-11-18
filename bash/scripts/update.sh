#!/usr/bin/env bash

set -ueo pipefail
IFS=$'\n\t'

PUSH_POP_CLOSE_STRING=''
pud () {
    OPEN_STRING="########## UPDATING ${1^^} ##########"
    IFS=' ' PUSH_POP_CLOSE_STRING=$(printf '#%.0s' $(eval echo {1..${#OPEN_STRING}}))
    printf "${OPEN_STRING}\n"
    pushd $1 >/dev/null
}

pod () {
    set +u; suffix=${1}; set -u
    popd >/dev/null
    printf "${PUSH_POP_CLOSE_STRING}${suffix}"
    PUSH_POP_CLOSE_STRING=''
}

#pud autorandr
#git pull
#pod "\n\n"

pud comp-setup
git pull
pod "\n\n"

pud comp-setup/emacs-doom/doom-emacs
if [[ $(date "+%A") == "Monday" ]]; then
    bin/doom clean
    bin/doom --yes upgrade
    bin/doom --yes compile :core
else
    printf "Skipping for today...\n"
fi
pod "\n\n"

pud diff-so-fancy
git fetch
git checkout tags/$(git tag --list | tail -1)
pod "\n\n"

### FuZzy Finder ###
#pud fzf
#git pull
#./install --all
#pod "\n\n"

#pud pyenv
#git pull
#pod "\n\n"

#pud rbenv
#git pull
#pod "\n\n"

#pud ruby-build
#git pull
#pod "\n\n"

#pud chemacs
#git pull
#pod "\n\n"

#pud yakuake-init
#git pull
#pod "\n\n"
