#!/bin/bash

set -eou pipefail
IFS=$'\n\t'

# Won't work in 100% of our cases (http://mywiki.wooledge.org/BashFAQ/028) but it'll do for now.
pushd "${BASH_SOURCE[@]%/*}/" >/dev/null
SOURCE_DIR=$(pwd)
popd >/dev/null
DOOM_DIR="${HOME}/.config/doom"

mkdir --parents "${DOOM_DIR}"
ln --symbolic --force "${SOURCE_DIR}/doom-emacs" "${HOME}/.emacs.d"
ln --symbolic --force --target-directory="${DOOM_DIR}" "${SOURCE_DIR}/config.org"
ln --symbolic --force --target-directory="${DOOM_DIR}" "${SOURCE_DIR}/init.el"
ln --symbolic --force --target-directory="${DOOM_DIR}" "${SOURCE_DIR}/packages.el"

cd "${SOURCE_DIR}/doom"
if ! [[ -f ".git" ]]; then
    git submodule init
    git submodule update
fi
bin/doom install
