#!/bin/bash

set -eou pipefail
IFS=$'\n\t'

# Won't work in 100% of our cases (http://mywiki.wooledge.org/BashFAQ/028) but it'll do for now.
SOURCE_DIR="${BASH_SOURCE[@]%/*}/"

[[ -d ~/.emacs.d ]] || mkdir ~/.emacs.d
ln --symbolic --force ${SOURCE_DIR}/.emacs ~/.emacs
ln --symbolic --force --no-target-directory ${SOURCE_DIR}/elpa ~/.emacs.d/elpa
ln --symbolic --force --no-target-directory ${SOURCE_DIR}/init ~/.emacs.d/init
