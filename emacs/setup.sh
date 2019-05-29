#!/bin/bash

set -eou pipefail
IFS=$'\n\t'

# Won't work in 100% of our cases (http://mywiki.wooledge.org/BashFAQ/028) but it'll do for now.
pushd "${BASH_SOURCE[@]%/*}/" >/dev/null
SOURCE_DIR=$(pwd)
popd >/dev/null

[[ -d ~/.emacs.d ]] || mkdir ~/.emacs.d
ln --symbolic --force ${SOURCE_DIR}/init.el ~/.emacs.d/init.el
ln --symbolic --force --no-target-directory ${SOURCE_DIR}/elpa ~/.emacs.d/elpa
ln --symbolic --force --no-target-directory ${SOURCE_DIR}/init ~/.emacs.d/init
